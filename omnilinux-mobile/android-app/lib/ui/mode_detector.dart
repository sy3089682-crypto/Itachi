/// Display Mode Detector
/// 
/// Auto-detect device mode:
/// - Phone (Portrait, <7 inches)
/// - Tablet (Landscape, 7-13 inches, or foldable unfolded)
/// - Desktop (External display connected)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum DisplayMode { phone, tablet, desktop }

class DisplayModeDetector {
  static DisplayMode? _cachedMode;
  
  /// Detect current display mode
  static DisplayMode detect() {
    if (_cachedMode != null) {
      return _cachedMode!;
    }
    
    // Check for external display first (highest priority)
    if (_isExternalDisplayConnected()) {
      _cachedMode = DisplayMode.desktop;
      return DisplayMode.desktop;
    }
    
    // Get screen metrics
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    final aspectRatio = size.aspectRatio;
    final diagonalInches = _calculateDiagonalInches(size);
    
    // Determine mode based on size and orientation
    if (diagonalInches < 7) {
      _cachedMode = DisplayMode.phone;
      return DisplayMode.phone;
    } else if (diagonalInches < 13) {
      _cachedMode = DisplayMode.tablet;
      return DisplayMode.tablet;
    } else {
      _cachedMode = DisplayMode.desktop;
      return DisplayMode.desktop;
    }
  }
  
  /// Check if external display is connected via USB-C DP Alt Mode / DisplayLink / Miracast
  static bool _isExternalDisplayConnected() {
    try {
      // On Android, check for HDMI/USB-C display connection
      if (Platform.isAndroid) {
        // In production: use android_thermal or custom platform channel
        // to query DisplayManager for external displays
        
        // Placeholder: check environment variable (for testing)
        final hasExternal = Platform.environment['OMNILINUX_EXTERNAL_DISPLAY'];
        return hasExternal == 'true';
      }
      
      return false;
    } catch (e) {
      print('[ModeDetector] Error checking external display: $e');
      return false;
    }
  }
  
  /// Calculate screen diagonal in inches
  static double _calculateDiagonalInches(Size physicalSize) {
    // Get DPI from platform
    final dpi = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio * 160;
    
    // Calculate physical dimensions in inches
    final widthInches = physicalSize.width / dpi;
    final heightInches = physicalSize.height / dpi;
    
    // Calculate diagonal using Pythagorean theorem
    return (widthInches * widthInches + heightInches * heightInches).sqrt();
  }
  
  /// Get detailed device information
  static Future<DeviceInfo> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return DeviceInfo(
        model: androidInfo.model,
        manufacturer: androidInfo.manufacturer,
        brand: androidInfo.brand,
        versionRelease: androidInfo.version.release,
        sdkInt: androidInfo.version.sdkInt,
        hardware: androidInfo.hardware,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return DeviceInfo(
        model: iosInfo.model,
        manufacturer: 'Apple',
        brand: 'Apple',
        versionRelease: iosInfo.systemVersion,
        sdkInt: 0,
        hardware: iosInfo.model,
        isPhysicalDevice: iosInfo.isPhysicalDevice,
      );
    }
    
    throw UnsupportedError('Platform not supported');
  }
  
  /// Check if device meets minimum requirements
  static Future<bool> meetsMinimumRequirements() async {
    final info = await getDeviceInfo();
    
    // Minimum: Snapdragon 7 Gen 3+ / Dimensity 8300+ / Apple A15+, 4GB RAM
    // Simplified check - in production, would benchmark CPU/GPU
    
    if (info.manufacturer == 'Samsung' || info.manufacturer == 'Google') {
      // Assume flagship/mid-range meets requirements
      return true;
    } else if (info.manufacturer == 'Apple') {
      // A15+ required
      return true; // Simplified
    }
    
    // Default to true with warning
    print('[ModeDetector] Device may not meet minimum requirements');
    return true;
  }
  
  /// Clear cached mode (call on orientation change)
  static void clearCache() {
    _cachedMode = null;
  }
  
  /// Listen for mode changes
  static Stream<DisplayMode> get modeChanges async* {
    DisplayMode previousMode = detect();
    
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      
      final currentMode = detect();
      if (currentMode != previousMode) {
        previousMode = currentMode;
        yield currentMode;
      }
    }
  }
}

/// Device information wrapper
class DeviceInfo {
  final String model;
  final String? manufacturer;
  final String? brand;
  final String? versionRelease;
  final int sdkInt;
  final String? hardware;
  final bool isPhysicalDevice;
  
  DeviceInfo({
    required this.model,
    this.manufacturer,
    this.brand,
    this.versionRelease,
    required this.sdkInt,
    this.hardware,
    required this.isPhysicalDevice,
  });
  
  @override
  String toString() {
    return '$manufacturer $model (Android $versionRelease, SDK $sdkInt)';
  }
}

/// Extension for Size class
extension SizeExtension on Size {
  double get aspectRatio {
    return width / height;
  }
}
