#!/bin/bash
# OMNILINUX MOBILE - Comprehensive Test Suite v3.5
# Tests all components for correctness, performance, and reliability

set -e

echo "🧪 OMNILINUX MOBILE v3.5 - Test Suite"
echo "======================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_ROOT/android-app/assets"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

log_pass() { 
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

log_fail() { 
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

log_warn() { 
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

log_info() { 
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Test 1: Verify proot binary exists and is valid
test_proot_binary() {
    log_info "Testing proot binary..."
    
    local proot_path="$ASSETS_DIR/bin/proot"
    
    if [ ! -f "$proot_path" ]; then
        log_fail "proot binary not found at $proot_path"
        return 1
    fi
    
    if [ ! -x "$proot_path" ]; then
        log_fail "proot binary is not executable"
        return 1
    fi
    
    # Check if it's a shell script placeholder or actual binary
    if head -c 4 "$proot_path" | grep -q "#!/"; then
        log_warn "proot is a shell script placeholder (actual binary needed for production)"
        log_info "Download real proot from: https://github.com/termux/proot/releases"
    elif head -c 4 "$proot_path" | od -A n -t x1 | grep -q "7f 45 4c 46"; then
        log_pass "proot binary is valid ELF executable"
    else
        log_fail "proot binary format unknown"
        return 1
    fi
    
    local size=$(du -h "$proot_path" | cut -f1)
    log_info "proot size: $size"
}

# Test 2: Verify Alpine rootfs exists and is valid
test_alpine_rootfs() {
    log_info "Testing Alpine rootfs..."
    
    local rootfs_path="$ASSETS_DIR/rootfs/alpine-rootfs.tar.gz"
    
    if [ ! -f "$rootfs_path" ]; then
        log_fail "Alpine rootfs not found at $rootfs_path"
        return 1
    fi
    
    # Check if it's a valid gzip file
    if ! gzip -t "$rootfs_path" 2>/dev/null; then
        log_fail "Alpine rootfs is not a valid gzip file"
        return 1
    fi
    
    # Check contents - look for bin directory anywhere in tarball
    if tar -tzf "$rootfs_path" | grep -q "^./bin/"; then
        log_pass "Alpine rootfs contains expected structure"
    else
        log_fail "Alpine rootfs structure invalid"
        return 1
    fi
    
    local size=$(du -h "$rootfs_path" | cut -f1)
    log_info "rootfs size: $size"
    
    # Count packages
    local file_count=$(tar -tzf "$rootfs_path" | wc -l)
    log_info "rootfs file count: $file_count"
}

# Test 3: Verify seccomp policy
test_seccomp_policy() {
    log_info "Testing seccomp policy..."
    
    local policy_path="$ASSETS_DIR/seccomp/seccomp_policy.json"
    
    if [ ! -f "$policy_path" ]; then
        log_fail "Seccomp policy not found"
        return 1
    fi
    
    # Validate JSON
    if command -v python3 &> /dev/null; then
        if python3 -c "import json; json.load(open('$policy_path'))" 2>/dev/null; then
            log_pass "Seccomp policy is valid JSON"
        else
            log_fail "Seccomp policy is invalid JSON"
            return 1
        fi
    else
        log_warn "python3 not available, skipping JSON validation"
    fi
    
    # Check for required syscalls
    if grep -q "execve" "$policy_path" && grep -q "openat" "$policy_path"; then
        log_pass "Seccomp policy contains essential syscalls"
    else
        log_fail "Seccomp policy missing essential syscalls"
        return 1
    fi
}

# Test 4: Verify Flutter project structure
test_flutter_structure() {
    log_info "Testing Flutter project structure..."
    
    local flutter_dir="$PROJECT_ROOT/android-app"
    
    # Check pubspec.yaml
    if [ -f "$flutter_dir/pubspec.yaml" ]; then
        log_pass "pubspec.yaml exists"
    else
        log_fail "pubspec.yaml not found"
        return 1
    fi
    
    # Check main.dart
    if [ -f "$flutter_dir/lib/main.dart" ]; then
        log_pass "main.dart exists"
    else
        log_fail "main.dart not found"
        return 1
    fi
    
    # Check key libraries
    local libs=("linux_engine.dart" "proot_integration.dart" "container_manager.dart" "ai_governor.dart")
    for lib in "${libs[@]}"; do
        if [ -f "$flutter_dir/lib/core/$lib" ]; then
            log_pass "$lib exists"
        else
            log_warn "$lib not found"
        fi
    done
    
    # Check UI components
    local ui_components=("morphos_app.dart" "terminal_view.dart" "gesture_handler.dart")
    for component in "${ui_components[@]}"; do
        if [ -f "$flutter_dir/lib/ui/$component" ]; then
            log_pass "$component exists"
        else
            log_warn "$component not found"
        fi
    done
}

# Test 5: Run Dart analysis
test_dart_analysis() {
    log_info "Running Dart analysis..."
    
    if ! command -v dart &> /dev/null; then
        log_warn "Dart not installed, skipping analysis"
        return 0
    fi
    
    cd "$PROJECT_ROOT/android-app"
    
    if dart analyze 2>&1 | tee /tmp/dart_analysis.log; then
        log_pass "Dart analysis passed"
    else
        log_fail "Dart analysis found issues (see /tmp/dart_analysis.log)"
    fi
    
    cd "$PROJECT_ROOT"
}

# Test 6: Run Flutter tests
test_flutter_tests() {
    log_info "Running Flutter tests..."
    
    if ! command -v flutter &> /dev/null; then
        log_warn "Flutter not installed, skipping tests"
        return 0
    fi
    
    cd "$PROJECT_ROOT/android-app"
    
    if flutter test 2>&1 | tee /tmp/flutter_tests.log; then
        log_pass "Flutter tests passed"
    else
        log_fail "Flutter tests failed (see /tmp/flutter_tests.log)"
    fi
    
    cd "$PROJECT_ROOT"
}

# Test 7: Verify documentation
test_documentation() {
    log_info "Testing documentation..."
    
    local docs_dir="$PROJECT_ROOT/docs"
    
    local required_docs=("GETTING_STARTED.md" "IMPLEMENTATION_COMPLETE.md")
    for doc in "${required_docs[@]}"; do
        if [ -f "$docs_dir/$doc" ]; then
            log_pass "$doc exists"
            
            # Check word count
            local words=$(wc -w < "$docs_dir/$doc")
            if [ "$words" -gt 100 ]; then
                log_pass "$doc has sufficient content ($words words)"
            else
                log_warn "$doc seems too short ($words words)"
            fi
        else
            log_fail "$doc not found"
        fi
    done
}

# Test 8: Verify scripts
test_scripts() {
    log_info "Testing scripts..."
    
    local scripts=("build-all.sh")
    for script in "${scripts[@]}"; do
        local script_path="$PROJECT_ROOT/scripts/$script"
        
        if [ -f "$script_path" ]; then
            log_pass "$script exists"
            
            if [ -x "$script_path" ]; then
                log_pass "$script is executable"
            else
                log_warn "$script is not executable"
            fi
            
            # Check for shebang
            if head -n1 "$script_path" | grep -q "^#!/"; then
                log_pass "$script has proper shebang"
            else
                log_fail "$script missing shebang"
            fi
        else
            log_fail "$script not found"
        fi
    done
}

# Test 9: File integrity checks
test_file_integrity() {
    log_info "Running file integrity checks..."
    
    # Check for empty files
    local empty_files=$(find "$PROJECT_ROOT" -type f -empty -not -path "*/\.*" -not -path "*/assets/*" 2>/dev/null | wc -l)
    
    if [ "$empty_files" -eq 0 ]; then
        log_pass "No empty files found"
    else
        log_warn "Found $empty_files empty files"
    fi
    
    # Check for TODO comments
    local todo_count=$(grep -r "TODO" "$PROJECT_ROOT" --include="*.dart" --include="*.rs" --include="*.sh" 2>/dev/null | wc -l || echo 0)
    
    if [ "$todo_count" -eq 0 ]; then
        log_pass "No TODO comments found"
    else
        log_warn "Found $todo_count TODO comments"
    fi
}

# Test 10: Performance benchmarks (if binaries available)
test_performance() {
    log_info "Running performance tests..."
    
    if [ ! -f "$ASSETS_DIR/bin/proot" ]; then
        log_warn "proot not available, skipping performance tests"
        return 0
    fi
    
    # Test proot startup time (simulated)
    local start_time=$(date +%s%N)
    
    # Just verify the binary can be read
    if file "$ASSETS_DIR/bin/proot" > /dev/null 2>&1; then
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        
        if [ "$duration" -lt 100 ]; then
            log_pass "Binary access time: ${duration}ms (<100ms)"
        else
            log_warn "Binary access time: ${duration}ms (>100ms)"
        fi
    else
        log_fail "Cannot access proot binary"
    fi
}

# Generate test report
generate_report() {
    echo ""
    echo "========================================"
    echo "           TEST SUMMARY"
    echo "========================================"
    echo -e "${GREEN}Passed:${NC}  $PASS_COUNT"
    echo -e "${RED}Failed:${NC}  $FAIL_COUNT"
    echo -e "${YELLOW}Warnings:${NC} $WARN_COUNT"
    echo "========================================"
    
    local total=$((PASS_COUNT + FAIL_COUNT))
    if [ "$total" -gt 0 ]; then
        local pass_rate=$((PASS_COUNT * 100 / total))
        echo "Pass rate: ${pass_rate}%"
    fi
    
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo -e "${GREEN}All critical tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed. Please review.${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo ""
    
    test_proot_binary
    test_alpine_rootfs
    test_seccomp_policy
    test_flutter_structure
    test_dart_analysis
    test_flutter_tests
    test_documentation
    test_scripts
    test_file_integrity
    test_performance
    
    generate_report
}

main "$@"
