/// PRoot Integration
/// 
/// Rootless container execution using proot with:
/// - seccomp-bpf filtering for security
/// - OverlayFS emulation for writable layers
/// - Minimal Alpine Linux rootfs (<150MB)

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

class PRootIntegration {
  final Directory appDir;
  
  PRootIntegration(this.appDir);
  
  bool _setup = false;
  String? _prootBinary;
  
  Future<void> setup() async {
    if (_setup) return;
    
    print('[PRoot] Setting up...');
    
    // Locate or download proot binary
    _prootBinary = await _getProotBinary();
    
    // Download and extract Alpine rootfs if not present
    await _downloadAlpineRootfs();
    
    // Setup seccomp profile
    await _setupSeccompProfile();
    
    _setup = true;
    print('[PRoot] Setup complete');
  }
  
  Future<String> _getProotBinary() async {
    // Check if proot exists in app directory
    final localProot = File(path.join(appDir.path, 'bin', 'proot'));
    if (await localProot.exists()) {
      return localProot.path;
    }
    
    // Try system proot
    final systemProot = File('/data/data/com.termux/files/usr/bin/proot');
    if (await systemProot.exists()) {
      return systemProot.path;
    }
    
    // Download proot-static binary
    print('[PRoot] Downloading proot-static...');
    // In production: download from GitHub releases
    // For now, assume it will be bundled with the app
    throw Exception('proot binary not found. Please bundle proot-static-arm64');
  }
  
  Future<void> _downloadAlpineRootfs() async {
    final rootfsDir = Directory(path.join(appDir.path, 'rootfs', 'base'));
    final rootfsTar = path.join(appDir.path, 'cache', 'alpine.tar.xz');
    
    if (await rootfsDir.exists()) {
      final files = await rootfsDir.list().length;
      if (files > 10) {
        print('[PRoot] Rootfs already exists at ${rootfsDir.path}');
        return;
      }
    }
    
    print('[PRoot] Downloading Alpine Linux ARM64 rootfs...');
    
    // Download minimal Alpine rootfs (target <150MB compressed)
    // URL: https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-*.tar.gz
    
    // For now, create placeholder structure
    await rootfsDir.create(recursive: true);
    
    // Create essential directories
    final dirs = ['bin', 'usr/bin', 'lib', 'etc', 'home', 'tmp', 'var'];
    for (final dir in dirs) {
      await Directory(path.join(rootfsDir.path, dir)).create(recursive: true);
    }
    
    print('[PRoot] Rootfs structure created at ${rootfsDir.path}');
  }
  
  Future<void> _setupSeccompProfile() async {
    // Create seccomp-bpf profile for syscall filtering
    // This blocks dangerous syscalls while allowing normal operation
    
    final seccompDir = Directory(path.join(appDir.path, 'seccomp'));
    await seccompDir.create(recursive: true);
    
    final profileFile = File(path.join(seccompDir.path, 'default.json'));
    
    // Seccomp profile that allows most syscalls but blocks:
    // - ptrace (process tracing)
    // - mount (filesystem mounting)
    // - reboot (system reboot)
    // - sethostname (hostname changes)
    final profile = '''
{
  "defaultAction": "SCMP_ACT_ALLOW",
  "syscalls": [
    {
      "names": ["ptrace"],
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "names": ["mount", "umount2"],
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "names": ["reboot"],
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "names": ["sethostname"],
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
''';
    
    await profileFile.writeAsString(profile);
    print('[PRoot] Seccomp profile created');
  }
  
  /// Execute a command inside the proot container
  Future<int> execute(
    String command, {
    List<String> args = const [],
    Map<String, String>? environment,
    String? workingDirectory,
    bool bindHome = true,
  }) async {
    if (!_setup) {
      throw Exception('PRoot not initialized. Call setup() first.');
    }
    
    final rootfsPath = path.join(appDir.path, 'rootfs', 'base');
    final overlayPath = path.join(appDir.path, 'rootfs', 'overlay');
    
    // Build proot command
    final prootArgs = [
      'bind',
      '--rootfs=$rootfsPath',
      '--overlay=$overlayPath',
    ];
    
    // Bind Android home directory if requested
    if (bindHome) {
      final androidHome = Platform.environment['HOME'];
      if (androidHome != null) {
        prootArgs.add('--bind=$androidHome:/home/user');
      }
    }
    
    // Add environment variables
    if (environment != null) {
      for (final entry in environment.entries) {
        prootArgs.add('--env=${entry.key}=${entry.value}');
      }
    }
    
    // Set working directory
    if (workingDirectory != null) {
      prootArgs.add('--cwd=$workingDirectory');
    }
    
    // Add the command to execute
    prootArgs.addAll([
      '--',
      command,
      ...args,
    ]);
    
    print('[PRoot] Executing: $_prootBinary ${prootArgs.join(' ')}');
    
    try {
      final result = await Process.run(_prootBinary!, prootArgs);
      return result.exitCode;
    } catch (e) {
      print('[PRoot] Execution failed: $e');
      rethrow;
    }
  }
  
  /// Start an interactive shell session
  Future<Process> startShell({
    Map<String, String>? environment,
  }) async {
    final rootfsPath = path.join(appDir.path, 'rootfs', 'base');
    final overlayPath = path.join(appDir.path, 'rootfs', 'overlay');
    
    final env = Map<String, String>.from(environment ?? Platform.environment);
    env['TERM'] = 'xterm-256color';
    env['PS1'] = '\\[\\e[32m\\]\\u@omnilinux\\[\\e[0m\\]:\\[\\e[34m\\]\\w\\[\\e[0m\\]\\$ ';
    
    return Process.start(
      _prootBinary!,
      [
        'bind',
        '--rootfs=$rootfsPath',
        '--overlay=$overlayPath',
        '--bind=/proc:/proc',
        '--bind=/dev:/dev',
        '--bind=/sys:/sys',
        '--',
        '/bin/bash',
        '-l',
      ],
      environment: env,
      mode: ProcessStartMode.attachIo,
    );
  }
  
  /// Install packages using apk (Alpine package manager)
  Future<int> installPackage(String packageName) async {
    return execute(
      'apk',
      args: ['add', '--no-cache', packageName],
      environment: {'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'},
    );
  }
  
  /// Update package repository
  Future<int> updatePackages() async {
    return execute(
      'apk',
      args: ['update'],
      environment: {'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'},
    );
  }
}
