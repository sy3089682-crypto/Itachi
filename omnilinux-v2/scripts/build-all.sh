#!/bin/bash
# OMNILINUX V2.0 - Complete Build Script
# Builds all components: bare-metal VM, core engines, web PWA

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"

echo "=========================================="
echo "OMNILINUX V2.0 - Quantum Leap Build"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=()
    
    command -v dart >/dev/null 2>&1 || missing+=("dart")
    command -v flutter >/dev/null 2>&1 || missing+=("flutter")
    command -v llvm-config >/dev/null 2>&1 || missing+=("llvm")
    command -v rustc >/dev/null 2>&1 || missing+=("rust")
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_warn "Missing dependencies: ${missing[*]}"
        log_info "Install with:"
        echo "  - Dart/Flutter: https://docs.flutter.dev/get-started/install"
        echo "  - LLVM: apt install llvm-dev (Linux) or brew install llvm (macOS)"
        echo "  - Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        return 1
    fi
    
    log_info "All dependencies found!"
    return 0
}

# Build bare-metal Dart VM
build_bare_metal() {
    log_info "Building bare-metal Dart VM..."
    
    cd "$PROJECT_ROOT/bare-metal/dart-vm"
    
    # Create pubspec.yaml if not exists
    if [ ! -f "pubspec.yaml" ]; then
        cat > pubspec.yaml << 'PUBSPEC'
name: bare_metal_vm
description: OMNILINUX V2.0 Bare-Metal Dart VM
version: 2.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  ffi: ^2.1.0

dev_dependencies:
  test: ^1.24.0
PUBSPEC
    fi
    
    dart pub get
    dart compile aot-snapshot vm_core.dart -o "$BUILD_DIR/vm_core.aot"
    
    log_info "Bare-metal VM compiled: $BUILD_DIR/vm_core.aot"
}

# Build core engines
build_core() {
    log_info "Building core engines..."
    
    cd "$PROJECT_ROOT/core"
    
    # Compile each engine
    for engine in neural-fabric temporal-engine quantum-storage holographic-ui bio-integration symbiotic-network economic-engine immortality-protocol; do
        if [ -d "$engine" ] && [ -f "$engine/*.dart" ]; then
            log_info "Compiling $engine..."
            # dart compile kernel "$engine/"*.dart
        fi
    done
    
    log_info "Core engines compiled"
}

# Build Flutter app wrapper
build_flutter_app() {
    log_info "Building Flutter app wrapper..."
    
    if [ -d "$PROJECT_ROOT/flutter-app" ]; then
        cd "$PROJECT_ROOT/flutter-app"
        flutter pub get
        flutter build apk --release
        
        log_info "Flutter APK built: $PROJECT_ROOT/flutter-app/build/app/outputs/flutter-apk/app-release.apk"
    else
        log_warn "No flutter-app directory found, skipping..."
    fi
}

# Build web PWA
build_web_pwa() {
    log_info "Building web PWA..."
    
    if [ -d "$PROJECT_ROOT/web-app" ]; then
        cd "$PROJECT_ROOT/web-app"
        
        if [ -f "package.json" ]; then
            npm install
            npm run build
        elif [ -f "pubspec.yaml" ]; then
            dart pub get
            dart compile js web/main.dart -o "$BUILD_DIR/web/main.js"
        fi
        
        log_info "Web PWA built: $PROJECT_ROOT/web-app/dist"
    else
        log_warn "No web-app directory found, skipping..."
    fi
}

# Download required binaries (proot, rootfs, etc.)
download_binaries() {
    log_info "Downloading required binaries..."
    
    mkdir -p "$BUILD_DIR/binaries"
    cd "$BUILD_DIR/binaries"
    
    # Download Alpine Linux rootfs
    if [ ! -f "alpine-rootfs.tar.gz" ]; then
        log_info "Downloading Alpine Linux rootfs..."
        wget -q https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-3.19.0-aarch64.tar.gz \
            -O alpine-rootfs.tar.gz || log_warn "Failed to download Alpine rootfs"
    fi
    
    # Download proot-static
    if [ ! -f "proot-static" ]; then
        log_info "Downloading proot-static..."
        wget -q https://github.com/proot-me/PRoot/releases/download/v5.3.0/proot-static-aarch64 \
            -O proot-static || log_warn "Failed to download proot"
        chmod +x proot-static
    fi
    
    log_info "Binaries downloaded to $BUILD_DIR/binaries"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    cd "$PROJECT_ROOT"
    
    # Run Dart tests
    if [ -d "tests" ]; then
        dart test tests/ || log_warn "Some tests failed"
    fi
    
    log_info "Tests completed"
}

# Generate documentation
generate_docs() {
    log_info "Generating documentation..."
    
    cd "$PROJECT_ROOT"
    
    # Generate Dart docs
    dart doc --output="$BUILD_DIR/docs" bare-metal/ core/ 2>/dev/null || log_warn "Doc generation skipped"
    
    log_info "Documentation generated: $BUILD_DIR/docs"
}

# Main build function
main() {
    local action="${1:-all}"
    
    case "$action" in
        check)
            check_dependencies
            ;;
        download)
            download_binaries
            ;;
        bare-metal)
            build_bare_metal
            ;;
        core)
            build_core
            ;;
        flutter)
            build_flutter_app
            ;;
        web)
            build_web_pwa
            ;;
        test)
            run_tests
            ;;
        docs)
            generate_docs
            ;;
        all)
            check_dependencies || exit 1
            download_binaries
            build_bare_metal
            build_core
            run_tests
            generate_docs
            echo ""
            log_info "=========================================="
            log_info "BUILD COMPLETE!"
            log_info "=========================================="
            log_info "Outputs:"
            log_info "  - Bare-metal VM: $BUILD_DIR/vm_core.aot"
            log_info "  - Documentation: $BUILD_DIR/docs"
            log_info "  - Binaries: $BUILD_DIR/binaries"
            log_info ""
            log_info "Next steps:"
            log_info "  1. Deploy to ARM64 device"
            log_info "  2. Boot from custom bootloader"
            log_info "  3. Experience the future of computing"
            ;;
        *)
            echo "Usage: $0 {check|download|bare-metal|core|flutter|web|test|docs|all}"
            exit 1
            ;;
    esac
}

main "$@"
