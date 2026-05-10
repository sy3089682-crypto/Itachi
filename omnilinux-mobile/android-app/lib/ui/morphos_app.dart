/// MorphOS App - Main UI Entry Point
/// 
/// Mobile-optimized interface that morphs between:
/// - Phone Mode (Portrait)
/// - Tablet Mode (Landscape/Split-pane)
/// - Desktop Mode (External display)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/linux_engine.dart';
import '../governor/ai_governor.dart';
import 'terminal_view.dart';
import 'gesture_handler.dart';
import 'mode_detector.dart';

class OmnilinuxMobileApp extends StatelessWidget {
  const OmnilinuxMobileApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TerminalState()),
        ChangeNotifierProvider(create: (_) => MorphOSState()),
      ],
      child: MaterialApp(
        title: 'Omnilinux Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          fontFamily: 'HackerMono',
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161B22),
            elevation: 0,
          ),
        ),
        home: const MorphosHome(),
      ),
    );
  }
}

class MorphosHome extends StatefulWidget {
  const MorphosHome({super.key});
  
  @override
  State<MorphosHome> createState() => _MorphosHomeState();
}

class _MorphosHomeState extends State<MorphosHome> {
  DisplayMode _currentMode = DisplayMode.phone;
  
  @override
  void initState() {
    super.initState();
    _detectMode();
  }
  
  void _detectMode() {
    final mode = DisplayModeDetector.detect();
    setState(() {
      _currentMode = mode;
    });
    
    // Update provider
    Provider.of<MorphOSState>(context, listen: false).setMode(mode);
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Intercept back button - minimize instead of exit
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main content based on mode
            _buildModeContent(),
            
            // Floating touchpad (phone mode only)
            if (_currentMode == DisplayMode.phone)
              const FloatingTouchpad(),
            
            // Gesture overlay
            GestureHandlerOverlay(
              onThreeFingerSwipeUp: () => _showAppSwitcher(),
              onThreeFingerSwipeDown: () => _goHome(),
              onFourFingerPinch: () => _showWorkspaceOverview(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeContent() {
    switch (_currentMode) {
      case DisplayMode.phone:
        return _buildPhoneMode();
      case DisplayMode.tablet:
        return _buildTabletMode();
      case DisplayMode.desktop:
        return _buildDesktopMode();
    }
  }
  
  /// PHONE MODE: Full-screen terminal with floating cards
  Widget _buildPhoneMode() {
    return Column(
      children: [
        // Status bar
        _buildStatusBar(),
        
        // Main terminal view
        const Expanded(
          child: TerminalView(),
        ),
        
        // Quick action bar
        _buildQuickActionBar(),
      ],
    );
  }
  
  /// TABLET MODE: Split-pane (Terminal 40%, GUI 60%)
  Widget _buildTabletMode() {
    return Row(
      children: [
        // Terminal pane (40%)
        const Expanded(
          flex: 2,
          child: TerminalView(),
        ),
        
        // Divider
        Container(
          width: 2,
          color: Colors.blue.withOpacity(0.3),
        ),
        
        // GUI pane (60%)
        const Expanded(
          flex: 3,
          child: GUIAppContainer(),
        ),
      ],
    );
  }
  
  /// DESKTOP MODE: Full desktop environment
  Widget _buildDesktopMode() {
    return DesktopEnvironment();
  }
  
  Widget _buildStatusBar() {
    return Consumer<AIGovernor>(
      builder: (context, governor, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF161B22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CPU/Memory stats
              Row(
                children: [
                  _StatChip(label: 'CPU', value: '12%'),
                  const SizedBox(width: 8),
                  _StatChip(label: 'RAM', value: '${LinuxEngine.instance.idleRAM}MB'),
                ],
              ),
              
              // Thermal indicator
              _ThermalIndicator(state: governor.thermalState),
              
              // Battery indicator
              _BatteryIndicator(state: governor.batteryState),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildQuickActionBar() {
    return Container(
      height: 60,
      color: const Color(0xFF161B22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(icon: Icons.terminal, label: 'Terminal'),
          _ActionButton(icon: Icons.folder, label: 'Files'),
          _ActionButton(icon: Icons.code, label: 'VS Code'),
          _ActionButton(icon: Icons.public, label: 'Browser'),
          _ActionButton(icon: Icons.settings, label: 'Settings'),
        ],
      ),
    );
  }
  
  void _showAppSwitcher() {
    print('[MorphOS] App switcher triggered');
    // Show recent apps overlay
  }
  
  void _goHome() {
    print('[MorphOS] Home triggered');
    // Minimize all windows
  }
  
  void _showWorkspaceOverview() {
    print('[MorphOS] Workspace overview triggered');
    // Show virtual desktops
  }
}

// Status bar widgets
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatChip({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
    );
  }
}

class _ThermalIndicator extends StatelessWidget {
  final ThermalState state;
  
  const _ThermalIndicator({required this.state});
  
  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (state) {
      case ThermalState.normal:
        color = Colors.green;
        icon = Icons.ac_unit;
        break;
      case ThermalState.warm:
        color = Colors.orange;
        icon = Icons.thermostat;
        break;
      case ThermalState.hot:
        color = Colors.red;
        icon = Icons.warning;
        break;
      case ThermalState.critical:
        color = Colors.red.shade900;
        icon = Icons.error;
        break;
    }
    
    return Icon(icon, color: color, size: 20);
  }
}

class _BatteryIndicator extends StatelessWidget {
  final BatteryState state;
  
  const _BatteryIndicator({required this.state});
  
  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (state) {
      case BatteryState.full:
        icon = Icons.battery_full;
        color = Colors.green;
        break;
      case BatteryState.medium:
        icon = Icons.battery_std;
        color = Colors.orange;
        break;
      case BatteryState.low:
        icon = Icons.battery_alert;
        color = Colors.red;
        break;
      case BatteryState.critical:
        icon = Icons.battery_unknown;
        color = Colors.red.shade900;
        break;
    }
    
    return Icon(icon, color: color, size: 20);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  
  const _ActionButton({required this.icon, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }
}

// Floating touchpad for phone mode
class FloatingTouchpad extends StatefulWidget {
  const FloatingTouchpad({super.key});
  
  @override
  State<FloatingTouchpad> createState() => _FloatingTouchpadState();
}

class _FloatingTouchpadState extends State<FloatingTouchpad> {
  Offset _position = const Offset(0, 0);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 76, // Above quick action bar
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
          // Send touch events to terminal
        },
        onTap: () {
          // Simulate left click
        },
        onLongPress: () {
          // Simulate right click
        },
        child: Container(
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Center(
            child: Icon(Icons.touch_app, color: Colors.white54, size: 24),
          ),
        ),
      ),
    );
  }
}

// Placeholder widgets for GUI apps and desktop
class GUIAppContainer extends StatelessWidget {
  const GUIAppContainer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('GUI Apps Area', style: TextStyle(color: Colors.white54)),
    );
  }
}

class DesktopEnvironment extends StatelessWidget {
  const DesktopEnvironment({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Desktop Environment', style: TextStyle(color: Colors.white54)),
    );
  }
}

// State classes
class TerminalState extends ChangeNotifier {
  String _output = '';
  bool _isRunning = false;
  
  String get output => _output;
  bool get isRunning => _isRunning;
  
  void appendOutput(String text) {
    _output += text;
    notifyListeners();
  }
  
  void setRunning(bool running) {
    _isRunning = running;
    notifyListeners();
  }
}

class MorphOSState extends ChangeNotifier {
  DisplayMode _mode = DisplayMode.phone;
  
  DisplayMode get mode => _mode;
  
  void setMode(DisplayMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
