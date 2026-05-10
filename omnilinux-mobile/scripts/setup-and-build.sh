#!/bin/bash
# OMNILINUX MOBILE v3.5 - Complete Build & Setup Script
# This script downloads all required binaries and builds the complete app

set -e

echo "🚀 OMNILINUX MOBILE v3.5 - Complete Setup"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../android-app"
ASSETS_DIR="$APP_DIR/assets"

# Create asset directories
mkdir -p "$ASSETS_DIR/bin"
mkdir -p "$ASSETS_DIR/rootfs"
mkdir -p "$ASSETS_DIR/configs"
mkdir -p "$ASSETS_DIR/seccomp"

echo ""
echo "📦 Step 1: Downloading proot binary..."
PROOT_URL="https://github.com/termux/proot/releases/download/v5.3.0/proot-aarch64"
if command -v curl &> /dev/null; then
    curl -L "$PROOT_URL" -o "$ASSETS_DIR/bin/proot"
elif command -v wget &> /dev/null; then
    wget -O "$ASSETS_DIR/bin/proot" "$PROOT_URL"
else
    echo "❌ Error: Neither curl nor wget found. Please install one."
    exit 1
fi
chmod +x "$ASSETS_DIR/bin/proot"
echo "✅ proot downloaded to $ASSETS_DIR/bin/proot"

echo ""
echo "📦 Step 2: Downloading Alpine Linux rootfs..."
ALPINE_VERSION="3.19.0"
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION%%.*}/releases/aarch64/alpine-minirootfs-${ALPINE_VERSION}-aarch64.tar.gz"
if command -v curl &> /dev/null; then
    curl -L "$ALPINE_URL" -o "$ASSETS_DIR/rootfs/alpine-rootfs.tar.gz"
elif command -v wget &> /dev/null; then
    wget -O "$ASSETS_DIR/rootfs/alpine-rootfs.tar.gz" "$ALPINE_URL"
else
    echo "❌ Error: Neither curl nor wget found."
    exit 1
fi
echo "✅ Alpine rootfs downloaded ($(wc -c < "$ASSETS_DIR/rootfs/alpine-rootfs.tar.gz") bytes)"

echo ""
echo "📦 Step 3: Creating seccomp policy..."
cat > "$ASSETS_DIR/seccomp/seccomp_policy.json" << 'SECCOMP_EOF'
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "syscalls": [
    {
      "names": [
        "accept", "access", "alarm", "bind", "brk", "capget", "capset",
        "chdir", "chmod", "chown", "chown32", "clock_getres", "clock_gettime",
        "clock_nanosleep", "close", "connect", "dup", "dup2", "dup3",
        "epoll_create", "epoll_create1", "epoll_ctl", "epoll_pwait", "epoll_wait",
        "eventfd", "eventfd2", "execve", "exit", "exit_group", "faccessat",
        "fadvise64", "fallocate", "fchdir", "fchmod", "fchmodat", "fchown",
        "fchown32", "fchownat", "fcntl", "fcntl64", "fdatasync", "fgetxattr",
        "flistxattr", "flock", "fork", "fsetxattr", "fstat", "fstat64",
        "fstatat64", "fstatfs", "fstatfs64", "fsync", "ftruncate", "ftruncate64",
        "futex", "futimesat", "getcwd", "getdents", "getdents64", "getegid",
        "getegid32", "geteuid", "geteuid32", "getgid", "getgid32", "getgroups",
        "getgroups32", "getitimer", "getpeername", "getpgid", "getpgrp", "getpid",
        "getppid", "getpriority", "getrandom", "getresgid", "getresgid32",
        "getresuid", "getresuid32", "getrlimit", "get_robust_list", "getrusage",
        "getsid", "getsockname", "getsockopt", "get_thread_area", "gettid",
        "gettimeofday", "getuid", "getuid32", "getxattr", "inotify_add_watch",
        "inotify_init", "inotify_init1", "inotify_rm_watch", "io_cancel",
        "ioctl", "io_destroy", "io_getevents", "ioprio_get", "ioprio_set",
        "kill", "lchown", "lchown32", "lgetxattr", "link", "linkat", "listen",
        "listxattr", "llistxattr", "_llseek", "lremovexattr", "lseek", "lsetxattr",
        "lstat", "lstat64", "madvise", "memfd_create", "mincore", "mkdir",
        "mkdirat", "mknod", "mknodat", "mlock", "mlock2", "mlockall", "mmap",
        "mmap2", "mprotect", "mq_getsetattr", "mq_notify", "mq_open",
        "mq_timedreceive", "mq_timedsend", "mq_unlink", "mremap", "msgctl",
        "msgget", "msgrcv", "msgsnd", "msync", "munlock", "munlockall", "munmap",
        "nanosleep", "newfstatat", "_newselect", "open", "openat", "pause",
        "pipe", "pipe2", "poll", "ppoll", "prctl", "pread64", "preadv", "prlimit64",
        "pselect6", "pwrite64", "pwritev", "read", "readahead", "readlink",
        "readlinkat", "readv", "recv", "recvfrom", "recvmmsg", "recvmsg", "remap_file_pages",
        "removexattr", "rename", "renameat", "renameat2", "restart_syscall",
        "rmdir", "rt_sigaction", "rt_sigpending", "rt_sigprocmask", "rt_sigqueueinfo",
        "rt_sigreturn", "rt_sigsuspend", "rt_sigtimedwait", "rt_tgsigqueueinfo",
        "sched_getaffinity", "sched_getattr", "sched_getparam", "sched_get_priority_max",
        "sched_get_priority_min", "sched_getscheduler", "sched_rr_get_interval",
        "sched_setaffinity", "sched_setattr", "sched_setparam", "sched_setscheduler",
        "sched_yield", "seccomp", "select", "semctl", "semget", "semop", "semtimedop",
        "send", "sendfile", "sendfile64", "sendmmsg", "sendmsg", "sendto", "setfsgid",
        "setfsgid32", "setfsuid", "setfsuid32", "setgid", "setgid32", "setgroups",
        "setgroups32", "setitimer", "setpgid", "setpriority", "setregid", "setregid32",
        "setresgid", "setresgid32", "setresuid", "setresuid32", "setreuid", "setreuid32",
        "setrlimit", "set_robust_list", "setsid", "setsockopt", "set_thread_area",
        "set_tid_address", "setuid", "setuid32", "setxattr", "shmat", "shmctl", "shmdt",
        "shmget", "shutdown", "sigaltstack", "signalfd", "signalfd4", "socket",
        "socketcall", "socketpair", "splice", "stat", "stat64", "statfs", "statfs64",
        "statx", "symlink", "symlinkat", "sync", "sync_file_range", "syncfs",
        "sysinfo", "tee", "tgkill", "time", "timer_create", "timer_delete",
        "timerfd_create", "timerfd_gettime", "timerfd_settime", "timer_getoverrun",
        "timer_gettime", "timer_settime", "times", "tkill", "truncate", "truncate64",
        "ugetrlimit", "umask", "uname", "unlink", "unlinkat", "utime", "utimensat",
        "utimes", "vfork", "vmsplice", "wait4", "waitid", "waitpid", "write", "writev"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
SECCOMP_EOF
echo "✅ Seccomp policy created"

echo ""
echo "📦 Step 4: Creating default configs..."
cat > "$ASSETS_DIR/configs/default_profile.json" << 'CONFIG_EOF'
{
  "name": "Default",
  "cpu_limit_percent": 100,
  "ram_limit_mb": 2048,
  "thermal_threshold_celsius": 45,
  "battery_save_mode": false,
  "auto_suspend_battery_percent": 15,
  "zram_enabled": true,
  "zram_compression_ratio": 2.0
}
CONFIG_EOF
echo "✅ Default config created"

echo ""
echo "📦 Step 5: Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter not found. Please install Flutter SDK:"
    echo "   https://docs.flutter.dev/get-started/install"
    echo ""
    echo "After installing Flutter, run:"
    echo "   cd $APP_DIR"
    echo "   flutter pub get"
    echo "   flutter build apk --release"
else
    echo "✅ Flutter found: $(flutter --version | head -1)"
    
    echo ""
    echo "🔨 Step 6: Installing Flutter dependencies..."
    cd "$APP_DIR"
    flutter pub get
    
    echo ""
    echo "🔨 Step 7: Building release APK..."
    flutter build apk --release
    
    echo ""
    echo "✅ BUILD COMPLETE!"
    echo "APK location: $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "To install on device:"
    echo "   adb install $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
fi

echo ""
echo "🎉 OMNILINUX MOBILE v3.5 setup complete!"
echo ""
echo "Next steps:"
echo "1. Connect Android device via USB"
echo "2. Enable USB debugging on device"
echo "3. Run: adb install -r android-app/build/app/outputs/flutter-apk/app-release.apk"
echo "4. Launch OMNILINUX MOBILE on your device"
echo "5. Type 'ls' in the terminal to verify it works"
