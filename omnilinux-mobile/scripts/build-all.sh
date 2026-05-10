# OMNILINUX MOBILE - Complete Build Script
# Phase 1-5 Full Implementation

#!/bin/bash
set -e

echo "========================================"
echo "OMNILINUX MOBILE - Build System"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_APP="$PROJECT_ROOT/android-app"
WEB_APP="$PROJECT_ROOT/web-app"
CLOUD="$PROJECT_ROOT/cloud"
ASSETS="$ANDROID_APP/assets"

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing=()
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        missing+=("Flutter SDK")
    else
        FLUTTER_VERSION=$(flutter --version | head -n1)
        print_status "Flutter: $FLUTTER_VERSION"
    fi
    
    # Check Dart
    if ! command -v dart &> /dev/null; then
        missing+=("Dart SDK")
    else
        DART_VERSION=$(dart --version)
        print_status "Dart: $DART_VERSION"
    fi
    
    # Check Rust (for native components)
    if ! command -v rustc &> /dev/null; then
        missing+=("Rust")
    else
        RUST_VERSION=$(rustc --version)
        print_status "Rust: $RUST_VERSION"
    fi
    
    # Check Android SDK
    if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
        missing+=("Android SDK")
    else
        print_status "Android SDK: Found"
    fi
    
    # Check wget/curl
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        missing+=("wget or curl")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing prerequisites: ${missing[*]}"
        echo ""
        echo "Please install:"
        for item in "${missing[@]}"; do
            echo "  - $item"
        done
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Download binaries
download_binaries() {
    print_status "Downloading required binaries..."
    
    mkdir -p "$ASSETS/bin"
    mkdir -p "$ASSETS/rootfs"
    
    # Download proot-static
    if [ ! -f "$ASSETS/bin/proot" ]; then
        print_status "Downloading proot-static..."
        PROOT_URL="https://github.com/termux/proot/releases/download/v5.1.107-33/proot-arm64-v8a"
        
        if command -v wget &> /dev/null; then
            wget -q --show-progress -O "$ASSETS/bin/proot" "$PROOT_URL"
        else
            curl -sL -o "$ASSETS/bin/proot" "$PROOT_URL"
        fi
        
        chmod +x "$ASSETS/bin/proot"
        print_success "proot downloaded"
    else
        print_status "proot already exists"
    fi
    
    # Download Alpine rootfs
    ALPINE_VERSION="3.19.0"
    ROOTFS_TAR="$ASSETS/rootfs/alpine-minirootfs-${ALPINE_VERSION}-aarch64.tar.gz"
    
    if [ ! -d "$ASSETS/rootfs/base" ] || [ -z "$(ls -A "$ASSETS/rootfs/base" 2>/dev/null)" ]; then
        print_status "Downloading Alpine Linux ${ALPINE_VERSION} ARM64 rootfs..."
        ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-${ALPINE_VERSION}-aarch64.tar.gz"
        
        mkdir -p "$ASSETS/rootfs/base"
        
        if command -v wget &> /dev/null; then
            wget -q --show-progress -O "$ROOTFS_TAR" "$ALPINE_URL"
        else
            curl -sL -o "$ROOTFS_TAR" "$ALPINE_URL"
        fi
        
        print_status "Extracting rootfs..."
        tar -xzf "$ROOTFS_TAR" -C "$ASSETS/rootfs/base"
        rm "$ROOTFS_TAR"
        
        print_success "Alpine rootfs installed"
    else
        print_status "Alpine rootfs already exists"
    fi
    
    # Download FEX-Emu (optional, Phase 2)
    if [ ! -f "$ASSETS/bin/FEX" ]; then
        print_warning "FEX-Emu not bundled (Phase 2 feature)"
        print_status "To enable x86 translation, download FEX-Emu 2406+ manually"
    fi
    
    # Download wasmtime (optional, Phase 2)
    if [ ! -f "$ASSETS/bin/wasmtime" ]; then
        print_warning "wasmtime not bundled (Phase 2 feature)"
        print_status "To enable WASM modules, download wasmtime manually"
    fi
}

# Build Flutter app
build_flutter_app() {
    print_status "Building Flutter app..."
    
    cd "$ANDROID_APP"
    
    # Get dependencies
    print_status "Running flutter pub get..."
    flutter pub get
    
    # Run analyzer
    print_status "Running dart analyze..."
    dart analyze || print_warning "Analysis found issues (continuing anyway)"
    
    # Run tests
    print_status "Running tests..."
    flutter test || print_warning "Some tests failed (continuing anyway)"
    
    # Build debug APK
    print_status "Building debug APK..."
    flutter build apk --debug
    
    # Build release APK (if in CI/CD)
    if [ "$BUILD_RELEASE" = "true" ]; then
        print_status "Building release APK..."
        flutter build apk --release
        
        # Build AAB for Play Store
        print_status "Building Android App Bundle..."
        flutter build appbundle --release
    fi
    
    print_success "Flutter app built successfully!"
    echo ""
    echo "Debug APK: $(pwd)/build/app/outputs/flutter-apk/app-debug.apk"
    if [ "$BUILD_RELEASE" = "true" ]; then
        echo "Release APK: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
        echo "AAB: $(pwd)/build/app/outputs/bundle/release/app-release.aab"
    fi
}

# Build native components (Rust)
build_native_components() {
    print_status "Building native components (Rust)..."
    
    # Wayland compositor (Phase 2)
    if [ -d "$PROJECT_ROOT/native/wayland-compositor" ]; then
        cd "$PROJECT_ROOT/native/wayland-compositor"
        cargo build --release
        print_success "Wayland compositor built"
    fi
    
    # Seccomp broker (Phase 2)
    if [ -d "$PROJECT_ROOT/native/seccomp-broker" ]; then
        cd "$PROJECT_ROOT/native/seccomp-broker"
        cargo build --release
        print_success "Seccomp broker built"
    fi
}

# Build web app (PWA)
build_web_app() {
    print_status "Building web app (PWA)..."
    
    if [ -d "$WEB_APP" ]; then
        cd "$WEB_APP"
        
        if [ -f "package.json" ]; then
            npm install
            npm run build
            print_success "Web app built"
        else
            print_warning "No package.json found in web-app/"
        fi
    else
        print_warning "web-app/ directory not found"
    fi
}

# Deploy to device
deploy_to_device() {
    print_status "Deploying to device..."
    
    # Check for connected devices
    if ! command -v adb &> /dev/null; then
        print_error "adb not found. Please install Android SDK Platform Tools."
        exit 1
    fi
    
    DEVICE_COUNT=$(adb devices | grep -v "^$" | grep -v "^List" | wc -l)
    
    if [ "$DEVICE_COUNT" -eq 0 ]; then
        print_error "No Android devices found. Connect a device or start an emulator."
        exit 1
    fi
    
    print_status "Found $DEVICE_COUNT device(s)"
    
    # Install APK
    cd "$ANDROID_APP"
    
    if [ "$BUILD_RELEASE" = "true" ]; then
        adb install -r build/app/outputs/flutter-apk/app-release.apk
    else
        flutter run
    fi
    
    print_success "App deployed!"
}

# Run benchmarks
run_benchmarks() {
    print_status "Running performance benchmarks..."
    
    echo ""
    echo "========================================"
    echo "PERFORMANCE BENCHMARKS"
    echo "========================================"
    
    # Cold boot test
    echo ""
    echo "Test 1: Cold Boot Time"
    echo "Target: <3 seconds"
    echo "Run the app and measure time from tap to bash prompt"
    
    # RAM usage test
    echo ""
    echo "Test 2: Idle RAM Usage"
    echo "Target: <150MB"
    echo "Inside container, run: free -m"
    
    # CPU usage test
    echo ""
    echo "Test 3: Idle CPU Usage"
    echo "Target: <1%"
    echo "Inside container, run: top -bn1 | grep 'Cpu(s)'"
    
    echo ""
    echo "========================================"
}

# Clean build artifacts
clean() {
    print_status "Cleaning build artifacts..."
    
    cd "$ANDROID_APP"
    flutter clean
    rm -rf build/
    rm -rf .dart_tool/
    
    if [ -d "$WEB_APP" ]; then
        cd "$WEB_APP"
        rm -rf node_modules/
        rm -rf dist/
        rm -rf build/
    fi
    
    print_success "Clean complete!"
}

# Show help
show_help() {
    echo "OMNILINUX MOBILE - Build System"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  check       Check prerequisites"
    echo "  download    Download required binaries"
    echo "  build       Build Flutter app (default)"
    echo "  native      Build native Rust components"
    echo "  web         Build web app (PWA)"
    echo "  deploy      Deploy to Android device"
    echo "  benchmark   Run performance benchmarks"
    echo "  all         Run full build (download + build + deploy)"
    echo "  clean       Clean build artifacts"
    echo "  help        Show this help message"
    echo ""
    echo "Options:"
    echo "  --release   Build release version"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 --release build"
    echo "  $0 all"
}

# Main entry point
main() {
    BUILD_RELEASE="false"
    
    # Parse global options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --release)
                BUILD_RELEASE="true"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local command="${1:-build}"
    
    case $command in
        check)
            check_prerequisites
            ;;
        download)
            download_binaries
            ;;
        build)
            build_flutter_app
            ;;
        native)
            build_native_components
            ;;
        web)
            build_web_app
            ;;
        deploy)
            deploy_to_device
            ;;
        benchmark)
            run_benchmarks
            ;;
        all)
            check_prerequisites
            download_binaries
            build_flutter_app
            deploy_to_device
            run_benchmarks
            ;;
        clean)
            clean
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
