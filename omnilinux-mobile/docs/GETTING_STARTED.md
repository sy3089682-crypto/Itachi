# OMNILINUX MOBILE - Getting Started Guide

## Prerequisites

### Development Environment
- **Flutter SDK**: 3.24.0 or later
- **Dart SDK**: 3.4.0 or later  
- **Android Studio**: Arctic Fox or later
- **Android SDK**: API level 29+ (Android 10+)
- **Rust**: 1.70+ (for native components)
- **Git**: For version control

### Hardware Requirements (for testing)
- **Minimum**: Snapdragon 7 Gen 3+ / Dimensity 8300+ / Apple A15+
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space
- **Display**: Any size (auto-detects phone/tablet/desktop mode)

## Phase 1 Setup (Core Engine)

### Step 1: Clone and Initialize

```bash
cd omnilinux-mobile/android-app
flutter pub get
```

### Step 2: Download Required Binaries

You need to bundle these binaries with the app:

```bash
# Create bin directory
mkdir -p android-app/assets/bin

# Download proot-static (ARM64)
wget https://github.com/termux/proot/releases/download/v5.1.107-33/proot-arm64-v8a
mv proot-arm64-v8a android-app/assets/bin/proot
chmod +x android-app/assets/bin/proot

# Download FEX-Emu (optional for Phase 1)
# wget https://github.com/FEX-Emu/FEX/releases/download/2406/FEX-2406-ARM64.tar.gz

# Download wasmtime (optional for Phase 1)
# wget https://github.com/bytecodealliance/wasmtime/releases/download/v19.0.0/wasmtime-v19.0.0-aarch64-linux.tar.xz
```

### Step 3: Download Alpine Rootfs

```bash
# Create rootfs directory
mkdir -p android-app/assets/rootfs

# Download minimal Alpine ARM64 rootfs
cd android-app/assets/rootfs
wget https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-3.19.0-aarch64.tar.gz

# Extract
tar xzf alpine-minirootfs-3.19.0-aarch64.tar.gz
rm alpine-minirootfs-3.19.0-aarch64.tar.gz
```

### Step 4: Build and Run

```bash
# Connect Android device or start emulator
adb devices

# Run in debug mode
flutter run

# Or build release APK
flutter build apk --release
```

## Architecture Overview

### Core Components

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── linux_engine.dart     # Hybrid execution matrix
│   ├── container_manager.dart # Container lifecycle
│   ├── proot_integration.dart # PRoot setup & execution
│   ├── fex_emu_bridge.dart   # x86→ARM translation
│   └── wasm_runtime.dart     # WASM execution
├── governor/
│   └── ai_governor.dart      # Resource management
└── ui/
    ├── morphos_app.dart      # Main UI
    ├── terminal_view.dart    # Terminal emulator
    ├── gesture_handler.dart  # Touch gestures
    └── mode_detector.dart    # Display mode detection
```

### Execution Flow

1. **App Launch** → AI Governor initializes
2. **Prediction** → Governor predicts needed services
3. **Container Setup** → Linux Engine creates proot container
4. **Service Start** → Predicted services pre-loaded
5. **UI Ready** → MorphOS displays terminal
6. **Monitoring** → Governor tracks thermal/battery/memory

## Performance Targets (Phase 1 Milestone)

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Cold boot | <3 seconds | `stopwatch` from tap to bash prompt |
| Idle RAM | <150MB | `free -m` inside container |
| Idle CPU | <1% | `top` over 60 seconds |
| Terminal response | <50ms | Type latency test |

## Testing Commands

Once running, test these commands in the terminal:

```bash
# System info
neofetch

# Package management
apk update
apk add python3 nodejs npm git vim

# Development
python3 --version
node --version
gcc --version

# Process monitoring
htop
ps aux

# File operations
ls -la
cd /home
touch test.txt
```

## Known Issues (Phase 1)

- [ ] proot binary must be bundled manually
- [ ] FEX-Emu integration incomplete (Phase 2)
- [ ] WASM runtime placeholder (Phase 2)
- [ ] GPU acceleration not implemented (Phase 2)
- [ ] Cloud sync not available (Phase 4)
- [ ] AI model is rule-based (Phase 5: TensorFlow Lite)

## Troubleshooting

### App crashes on launch
```bash
# Check logs
adb logcat | grep omnilinux

# Clear app data
adb shell pm clear com.omnilinux.mobile
```

### proot not found error
Ensure proot binary is in `assets/bin/proot` and has execute permissions.

### Container fails to start
Check that Alpine rootfs is extracted to `assets/rootfs/`.

## Next Steps (Phase 2)

After Phase 1 milestone is achieved:

1. **Wayland Compositor** - Build Rust-based compositor with smithay
2. **Touch Gestures** - Implement full gesture recognition
3. **FEX-Emu Integration** - Complete x86 translation layer
4. **External Display** - USB-C DP Alt Mode support
5. **GPU Acceleration** - Vulkan forwarding to host GPU

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

Core components: MIT License  
Enterprise features: Commercial License

---

**OMNILINUX MOBILE** - Universal Linux Runtime for Smartphones
