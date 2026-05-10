/// Linux Engine Core
/// 
/// Manages the Hybrid Execution Matrix:
/// - PATH 1: Native ARM Container (proot + Alpine)
/// - PATH 2: FEX-Emu x86/x64 Translator
/// - PATH 3: WASM-Native WASI-P2 Modules

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'container_manager.dart';
import 'proot_integration.dart';
import 'fex_emu_bridge.dart';
import 'wasm_runtime.dart';

enum ExecutionPath { nativeARM, fexX86, wasmNative }

class LinuxEngine {
  LinuxEngine._();
  static final LinuxEngine instance = LinuxEngine._();
  
  bool _initialized = false;
  DateTime? _bootStartTime;
  
  // Container management
  late final ContainerManager _containerManager;
  late final PRootIntegration _proot;
  late final FEXEmuBridge _fexEmu;
  late final WasmRuntime _wasmRuntime;
  
  // Performance metrics
  Duration get bootTime => DateTime.now().difference(_bootStartTime!);
  int get idleRAM => _containerManager.currentRAMUsage;
  
  Future<void> initialize({List<String>? predictedServices}) async {
    if (_initialized) return;
    
    _bootStartTime = DateTime.now();
    print('[LinuxEngine] Initializing at ${_bootStartTime}');
    
    // Get storage directories
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = await getTemporaryDirectory();
    
    // Initialize components in parallel for speed
    await Future.wait([
      _initContainerManager(appDir, cacheDir),
      _initProot(appDir),
      _initFEXEmu(appDir),
      _initWasmRuntime(appDir),
    ]);
    
    // Start predicted services
    if (predictedServices != null && predictedServices.isNotEmpty) {
      await _startPredictedServices(predictedServices);
    }
    
    _initialized = true;
    final bootDuration = bootTime;
    print('[LinuxEngine] Initialized in ${bootDuration.inMilliseconds}ms');
    print('[LinuxEngine] Idle RAM: ${idleRAM}MB');
    
    // Verify milestone targets
    assert(bootDuration.inSeconds < 3, 'Cold boot exceeded 3 second target');
    assert(idleRAM < 150, 'Idle RAM exceeded 150MB target');
  }
  
  Future<void> _initContainerManager(Directory appDir, Directory cacheDir) async {
    _containerManager = ContainerManager(appDir, cacheDir);
    await _containerManager.initialize();
  }
  
  Future<void> _initProot(Directory appDir) async {
    _proot = PRootIntegration(appDir);
    await _proot.setup();
  }
  
  Future<void> _initFEXEmu(Directory appDir) async {
    _fexEmu = FEXEmuBridge(appDir);
    await _fexEmu.initialize();
  }
  
  Future<void> _initWasmRuntime(Directory appDir) async {
    _wasmRuntime = WasmRuntime(appDir);
    await _wasmRuntime.initialize();
  }
  
  Future<void> _startPredictedServices(List<String> services) async {
    print('[LinuxEngine] Starting predicted services: $services');
    for (final service in services) {
      await spawnProcess(service, ExecutionPath.nativeARM);
    }
  }
  
  /// Spawn a process on the optimal execution path
  Future<int> spawnProcess(
    String command,
    ExecutionPath path, {
    List<String> args = const [],
    Map<String, String>? environment,
    String? workingDirectory,
  }) async {
    switch (path) {
      case ExecutionPath.nativeARM:
        return _proot.execute(command, args: args, environment: environment);
      case ExecutionPath.fexX86:
        return _fexEmu.execute(command, args: args);
      case ExecutionPath.wasmNative:
        return _wasmRuntime.execute(command, args: args);
    }
  }
  
  /// Auto-route based on binary analysis
  Future<int> autoRouteAndExecute(String binaryPath, List<String> args) async {
    final path = await _detectExecutionPath(binaryPath);
    return spawnProcess(binaryPath, path, args: args);
  }
  
  Future<ExecutionPath> _detectExecutionPath(String binaryPath) async {
    final file = File(binaryPath);
    if (!await file.exists()) {
      throw Exception('Binary not found: $binaryPath');
    }
    
    // Read ELF header to detect architecture
    final bytes = await file.readAsBytes();
    if (bytes.length < 20) {
      throw Exception('Invalid ELF file');
    }
    
    // e_machine field at offset 18-19 (little endian)
    final eMachine = bytes[18] | (bytes[19] << 8);
    
    // EM_AARCH64 = 183, EM_X86_64 = 62, EM_386 = 3
    if (eMachine == 183) {
      return ExecutionPath.nativeARM;
    } else if (eMachine == 62 || eMachine == 3) {
      return ExecutionPath.fexX86;
    }
    
    // Default to FEX-Emu for unknown architectures
    return ExecutionPath.fexX86;
  }
  
  /// Freeze session to disk (for battery saving or memory pressure)
  Future<void> freezeSession() async {
    await _containerManager.checkpoint();
    print('[LinuxEngine] Session frozen to disk');
  }
  
  /// Resume session from disk checkpoint
  Future<void> resumeSession() async {
    await _containerManager.restore();
    print('[LinuxEngine] Session resumed from disk');
  }
  
  /// Shutdown gracefully
  Future<void> shutdown() async {
    await _containerManager.stopAll();
    await _wasmRuntime.dispose();
    _initialized = false;
    print('[LinuxEngine] Shutdown complete');
  }
}
