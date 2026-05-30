#!/bin/bash

# ALONU App - Build & Release Script
# This script automates the build process for Android and iOS

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${GREEN}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

show_usage() {
    cat << EOF
ALONU App Build Script

Usage: ./build.sh [command] [options]

Commands:
    setup           Setup development environment
    clean           Clean build artifacts
    build-apk       Build APK for testing (Android)
    build-aab       Build App Bundle for Play Store (Android)
    build-ios       Build iOS app for App Store
    analyze         Run code analysis and linting
    test            Run unit tests
    release-prep    Prepare for release (all checks)
    help            Show this help message

Options:
    --version       Specify version (e.g., 1.0.0)
    --release       Build for production
    --debug         Build for debugging

Examples:
    ./build.sh setup                    # Setup environment
    ./build.sh build-apk --debug        # Build debug APK
    ./build.sh build-aab --version 1.0.0  # Build release bundle
    ./build.sh release-prep             # Prepare for release
EOF
}

# Setup environment
setup() {
    print_header "Setting up development environment"
    
    print_info "Installing dependencies..."
    flutter pub get
    
    print_info "Generating code..."
    dart run build_runner build --delete-conflicting-outputs
    
    print_success "Setup complete!"
}

# Clean build
clean() {
    print_header "Cleaning build artifacts"
    
    flutter clean
    rm -rf build/
    rm -rf .dart_tool/
    rm -rf pubspec.lock
    
    print_success "Clean complete!"
}

# Build Android APK
build_apk() {
    print_header "Building Android APK"
    
    if [ "$BUILD_MODE" = "release" ]; then
        print_info "Building release APK..."
        flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
        BUILD_OUTPUT="build/app/outputs/flutter-apk/app-release.apk"
    else
        print_info "Building debug APK..."
        flutter build apk --debug
        BUILD_OUTPUT="build/app/outputs/flutter-apk/app-debug.apk"
    fi
    
    if [ -f "$BUILD_OUTPUT" ]; then
        print_success "APK built successfully!"
        print_info "Output: $BUILD_OUTPUT"
        ls -lh "$BUILD_OUTPUT"
    else
        print_error "APK build failed!"
        exit 1
    fi
}

# Build Android App Bundle
build_aab() {
    print_header "Building Android App Bundle"
    
    print_info "Building App Bundle for Play Store..."
    flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
    
    BUILD_OUTPUT="build/app/outputs/bundle/release/app-release.aab"
    
    if [ -f "$BUILD_OUTPUT" ]; then
        print_success "App Bundle built successfully!"
        print_info "Output: $BUILD_OUTPUT"
        ls -lh "$BUILD_OUTPUT"
        print_info "Ready to upload to Google Play Console"
    else
        print_error "App Bundle build failed!"
        exit 1
    fi
}

# Build iOS
build_ios() {
    print_header "Building iOS app"
    
    print_info "Building iOS app..."
    flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols
    
    print_success "iOS app built successfully!"
    print_info "To submit to App Store:"
    print_info "1. Open ios/Runner.xcworkspace in Xcode"
    print_info "2. Select Product > Archive"
    print_info "3. Upload to App Store Connect"
}

# Code analysis
analyze() {
    print_header "Running code analysis"
    
    print_info "Running Flutter analyze..."
    flutter analyze
    
    print_info "Running tests..."
    flutter test
    
    print_success "Analysis complete!"
}

# Tests
run_tests() {
    print_header "Running unit tests"
    
    flutter test --coverage
    
    print_success "Tests complete!"
}

# Release preparation
release_prep() {
    print_header "Preparing for release"
    
    print_info "Step 1: Code analysis"
    flutter analyze
    
    print_info "Step 2: Running tests"
    flutter test
    
    print_info "Step 3: Cleaning build"
    flutter clean
    
    print_info "Step 4: Getting dependencies"
    flutter pub get
    
    print_info "Step 5: Generating code"
    dart run build_runner build --delete-conflicting-outputs
    
    print_success "Release preparation complete!"
    print_info "Next steps:"
    print_info "1. Update version in pubspec.yaml"
    print_info "2. Update CHANGELOG.md"
    print_info "3. Run: ./build.sh build-aab"
    print_info "4. Run: ./build.sh build-ios"
    print_info "5. Submit to app stores"
}

# Main script
main() {
    # Default values
    COMMAND="help"
    BUILD_MODE="debug"
    
    # Parse arguments
    for arg in "$@"; do
        case $arg in
            --release)
                BUILD_MODE="release"
                shift
                ;;
            --debug)
                BUILD_MODE="debug"
                shift
                ;;
            setup|clean|build-apk|build-aab|build-ios|analyze|test|release-prep|help)
                COMMAND="$arg"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    case $COMMAND in
        setup)
            setup
            ;;
        clean)
            clean
            ;;
        build-apk)
            build_apk
            ;;
        build-aab)
            build_aab
            ;;
        build-ios)
            build_ios
            ;;
        analyze)
            analyze
            ;;
        test)
            run_tests
            ;;
        release-prep)
            release_prep
            ;;
        help|*)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"
