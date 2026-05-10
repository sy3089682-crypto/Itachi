/// Gesture Handler
/// 
/// Touch gesture recognition for MorphOS:
/// - 2-finger tap = right-click
/// - 3-finger swipe up = Alt-Tab app switcher
/// - 3-finger swipe down = Home
/// - 4-finger pinch = Workspace overview
/// - Long-press drag = Window move

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GestureHandlerOverlay extends StatefulWidget {
  final VoidCallback? onTwoFingerTap;
  final VoidCallback? onThreeFingerSwipeUp;
  final VoidCallback? onThreeFingerSwipeDown;
  final VoidCallback? onFourFingerPinch;
  final Function(Offset)? onLongPressDrag;
  
  const GestureHandlerOverlay({
    super.key,
    this.onTwoFingerTap,
    this.onThreeFingerSwipeUp,
    this.onThreeFingerSwipeDown,
    this.onFourFingerPinch,
    this.onLongPressDrag,
  });
  
  @override
  State<GestureHandlerOverlay> createState() => _GestureHandlerOverlayState();
}

class _GestureHandlerOverlayState extends State<GestureHandlerOverlay> {
  int _fingerCount = 0;
  DateTime? _lastTapTime;
  Offset? _startPosition;
  bool _isLongPress = false;
  
  // Track individual pointers
  final Map<int, Offset> _pointers = {};
  
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      onPointerMove: _handlePointerMove,
      child: const IgnorePointer(
        child: SizedBox.expand(),
      ),
    );
  }
  
  void _handlePointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.position;
    _fingerCount = _pointers.length;
    
    print('[GestureHandler] Pointer down: ${_fingerCount} fingers');
    
    if (_fingerCount == 3) {
      _startPosition = event.position;
    } else if (_fingerCount == 4) {
      _startPosition = event.position;
    }
  }
  
  void _handlePointerUp(PointerUpEvent event) {
    _pointers.remove(event.pointer);
    _fingerCount = _pointers.length;
    
    print('[GestureHandler] Pointer up: ${_fingerCount} fingers remaining');
    
    // Detect two-finger tap (both fingers released within 100ms)
    if (_fingerCount == 0 && _lastTapTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastTapTime!).inMilliseconds < 100) {
        widget.onTwoFingerTap?.call();
        print('[GestureHandler] Two-finger tap detected');
      }
    }
    
    _lastTapTime = DateTime.now();
    _startPosition = null;
    _isLongPress = false;
  }
  
  void _handlePointerCancel(PointerCancelEvent event) {
    _pointers.remove(event.pointer);
    _fingerCount = _pointers.length;
    _startPosition = null;
    _isLongPress = false;
  }
  
  void _handlePointerMove(PointerMoveEvent event) {
    if (_pointers.containsKey(event.pointer)) {
      _pointers[event.pointer] = event.position;
    }
    
    // Detect 3-finger swipe
    if (_fingerCount == 3 && _startPosition != null && !_isLongPress) {
      final deltaY = event.position.dy - _startPosition!.dy;
      
      if (deltaY < -100) {
        // Swipe up
        widget.onThreeFingerSwipeUp?.call();
        print('[GestureHandler] Three-finger swipe UP');
        _resetGesture();
      } else if (deltaY > 100) {
        // Swipe down
        widget.onThreeFingerSwipeDown?.call();
        print('[GestureHandler] Three-finger swipe DOWN');
        _resetGesture();
      }
    }
    
    // Detect 4-finger pinch
    if (_fingerCount == 4 && _startPosition != null) {
      // Calculate average distance from center
      final center = Offset(
        _pointers.values.map((p) => p.dx).average,
        _pointers.values.map((p) => p.dy).average,
      );
      
      final avgDistance = _pointers.values
          .map((p) => (p - center).distance)
          .average;
      
      // If distances are decreasing = pinch in
      // If distances are increasing = pinch out
      // For simplicity, trigger on any 4-finger movement
      widget.onFourFingerPinch?.call();
      print('[GestureHandler] Four-finger pinch detected');
      _resetGesture();
    }
    
    // Detect long-press drag
    if (_isLongPress && _fingerCount == 1) {
      widget.onLongPressDrag?.call(event.delta);
    }
  }
  
  void _resetGesture() {
    _pointers.clear();
    _fingerCount = 0;
    _startPosition = null;
    _isLongPress = false;
  }
}

/// Alternative implementation using GestureDetector for simpler gestures
class MultiTouchGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(int)? onFingerCountChanged;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function()? onLongPress;
  final Function(Offset)? onPanUpdate;
  
  const MultiTouchGestureDetector({
    super.key,
    required this.child,
    this.onFingerCountChanged,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanUpdate,
  });
  
  @override
  State<MultiTouchGestureDetector> createState() =>
      _MultiTouchGestureDetectorState();
}

class _MultiTouchGestureDetectorState
    extends State<MultiTouchGestureDetector> {
  int _currentFingerCount = 0;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      onPanUpdate: (details) {
        widget.onPanUpdate?.call(details.delta);
      },
      child: Listener(
        onPointerDown: (event) {
          setState(() {
            _currentFingerCount++;
          });
          widget.onFingerCountChanged?.call(_currentFingerCount);
        },
        onPointerUp: (event) {
          setState(() {
            _currentFingerCount--;
          });
          widget.onFingerCountChanged?.call(_currentFingerCount);
        },
        onPointerCancel: (event) {
          setState(() {
            _currentFingerCount--;
          });
          widget.onFingerCountChanged?.call(_currentFingerCount);
        },
        child: widget.child,
      ),
    );
  }
}

/// Haptic feedback helper
class HapticFeedbackHelper {
  static void lightTap() {
    // In production: use HapticFeedback.lightImpact()
    print('[HapticFeedback] Light tap');
  }
  
  static void mediumTap() {
    // In production: use HapticFeedback.mediumImpact()
    print('[HapticFeedback] Medium tap');
  }
  
  static void heavyTap() {
    // In production: use HapticFeedback.heavyImpact()
    print('[HapticFeedback] Heavy tap');
  }
  
  static void selectionClick() {
    // In production: use HapticFeedback.selectionClick()
    print('[HapticFeedback] Selection click');
  }
}
