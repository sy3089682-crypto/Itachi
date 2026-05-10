/// OMNILINUX V2.0 - Biological Integration Module
/// 
/// The OS as a living extension of user biology.
/// Continuous monitoring of biometric signals to adapt the system
/// to the user's physical and mental state.
/// 
/// Sensors:
/// - Heart rate (PPG)
/// - Galvanic skin response (GSR)
/// - Brainwaves (EEG)
/// - Eye movement (EOG)
/// - Muscle tension (EMG)
/// - Blood oxygen (SpO2)
/// - Body temperature
/// - Cortisol levels (via sweat sensors)

import 'dart:math';

/// Biological Integration Engine
class BiologicalIntegration {
  // Biometric sensor data streams
  final BiometricSensor _heartRateSensor = BiometricSensor('HR');
  final BiometricSensor _gsrSensor = BiometricSensor('GSR');
  final BiometricSensor _eegSensor = BiometricSensor('EEG');
  final BiometricSensor _eogSensor = BiometricSensor('EOG');
  final BiometricSensor _emgSensor = BiometricSensor('EMG');
  final BiometricSensor _spo2Sensor = BiometricSensor('SpO2');
  final BiometricSensor _tempSensor = BiometricSensor('TEMP');
  
  // User state detection
  UserState _currentState = UserState.neutral;
  DateTime _stateStartTime = DateTime.now();
  
  // Health guardian
  final HealthGuardian _healthGuardian = HealthGuardian();
  
  // Energy optimization
  final EnergyOptimizer _energyOptimizer = EnergyOptimizer();
  
  // Callbacks for state changes
  Function(UserState)? onStateChanged;
  
  /// Initialize biological integration
  Future<void> initialize() async {
    print('[Bio] Initializing biological integration...');
    
    // Start all sensor streams
    await _heartRateSensor.start();
    await _gsrSensor.start();
    await _eegSensor.start();
    await _eogSensor.start();
    await _emgSensor.start();
    await _spo2Sensor.start();
    await _tempSensor.start();
    
    // Start health monitoring
    await _healthGuardian.initialize();
    
    // Start energy optimization
    await _energyOptimizer.initialize();
    
    // Begin state detection loop
    _startStateDetectionLoop();
    
    print('[Bio] Biological integration active.');
  }
  
  /// Continuous state detection loop
  void _startStateDetectionLoop() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      
      // Read all sensors
      final readings = _readAllSensors();
      
      // Detect current state
      final newState = _detectState(readings);
      
      // Handle state change
      if (newState != _currentState) {
        _handleStateChange(_currentState, newState);
        _currentState = newState;
        _stateStartTime = DateTime.now();
        
        if (onStateChanged != null) {
          onStateChanged!(newState);
        }
      }
      
      // Check for health anomalies
      await _healthGuardian.checkAnomalies(readings);
      
      // Optimize energy based on biological cycles
      await _energyOptimizer.optimize(readings, _currentState);
    }
  }
  
  /// Read all sensor values
  BiometricReadings _readAllSensors() {
    return BiometricReadings(
      heartRate: _heartRateSensor.read(),
      gsr: _gsrSensor.read(),
      eeg: _eegSensor.read(),
      eog: _eogSensor.read(),
      emg: _emgSensor.read(),
      spo2: _spo2Sensor.read(),
      temperature: _tempSensor.read(),
      timestamp: DateTime.now(),
    );
  }
  
  /// Detect user state from biometric readings
  UserState _detectState(BiometricReadings readings) {
    final hr = readings.heartRate;
    final gsr = readings.gsr;
    final eegAlpha = readings.eeg['alpha'] ?? 0;
    final eegBeta = readings.eeg['beta'] ?? 0;
    final eegTheta = readings.eeg['theta'] ?? 0;
    
    // Focused: High beta, moderate HR, low GSR
    if (eegBeta > 15 && hr < 90 && gsr < 3) {
      return UserState.focused;
    }
    
    // Creative: High alpha, moderate theta, relaxed HR
    if (eegAlpha > 20 && eegTheta > 10 && hr >= 60 && hr < 80) {
      return UserState.creative;
    }
    
    // Stressed: High HR, high GSR, high beta
    if (hr > 100 && gsr > 5 && eegBeta > 25) {
      return UserState.stressed;
    }
    
    // Tired: High theta, low HR, low GSR
    if (eegTheta > 20 && hr < 60 && gsr < 2) {
      return UserState.tired;
    }
    
    // Alert: Balanced waves, normal HR
    if (hr >= 70 && hr < 90 && eegAlpha >= 10 && eegBeta >= 10) {
      return UserState.alert;
    }
    
    return UserState.neutral;
  }
  
  /// Handle state transition
  void _handleStateChange(UserState oldState, UserState newState) {
    print('[Bio] State changed: $oldState → $newState');
    
    switch (newState) {
      case UserState.focused:
        _enterFocusedMode();
        break;
      case UserState.tired:
        _enterTiredMode();
        break;
      case UserState.stressed:
        _enterStressedMode();
        break;
      case UserState.creative:
        _enterCreativeMode();
        break;
      default:
        _enterNeutralMode();
    }
  }
  
  /// Focused mode optimizations
  void _enterFocusedMode() {
    print('[Bio] Focused mode activated');
    
    // Minimize distractions
    // Increase terminal font size
    // Boost CPU to max performance
    // Disable non-urgent notifications
    
    // In production: signal to UI and scheduler
  }
  
  /// Tired mode adaptations
  void _enterTiredMode() {
    print('[Bio] Tired mode activated');
    
    // Simplify UI
    // Enable voice input
    // Reduce blue light
    // Schedule complex tasks for later
    // Suggest break after 20 minutes
    
    // In production: signal to UI and scheduler
  }
  
  /// Stressed mode interventions
  void _enterStressedMode() {
    print('[Bio] Stressed mode activated');
    
    // Pause non-urgent notifications
    // Play calming ambient audio
    // Suggest break immediately
    // Simplify workflows
    // Enable breathing exercise prompt
    
    // In production: signal to UI and audio system
  }
  
  /// Creative mode enhancements
  void _enterCreativeMode() {
    print('[Bio] Creative mode activated');
    
    // Scatter inspirational content in peripheral vision
    // Enable freeform brainstorming mode
    // Disable time pressure indicators
    // Enable mind mapping tools
    
    // In production: signal to UI
  }
  
  /// Neutral/Alert mode
  void _enterNeutralMode() {
    print('[Bio] Normal mode active');
    // Standard operation
  }
  
  /// Get current user state
  UserState get currentState => _currentState;
  
  /// Get duration in current state
  Duration get stateDuration => DateTime.now().difference(_stateStartTime);
  
  /// Get comprehensive statistics
  BioStats getStatistics() {
    return BioStats(
      currentState: _currentState,
      stateDuration: stateDuration,
      heartRate: _heartRateSensor.read(),
      gsr: _gsrSensor.read(),
      stressLevel: _calculateStressLevel(),
      fatigueLevel: _calculateFatigueLevel(),
      healthAlerts: _healthGuardian.alertCount,
      energyOptimizations: _energyOptimizer.optimizationCount,
    );
  }
  
  double _calculateStressLevel() {
    // Combine HR, GSR, EEG into stress score (0-100)
    final hr = _heartRateSensor.read();
    final gsr = _gsrSensor.read();
    
    // Simplified calculation
    var stress = 0.0;
    stress += (hr - 60) / 60 * 40; // HR contribution (0-40)
    stress += gsr / 10 * 40; // GSR contribution (0-40)
    stress += (_currentState == UserState.stressed ? 20 : 0);
    
    return stress.clamp(0, 100);
  }
  
  double _calculateFatigueLevel() {
    // Combine EEG theta, HRV, time awake into fatigue score
    final eegTheta = _eegSensor.read()['theta'] ?? 0;
    
    // Simplified calculation
    var fatigue = eegTheta / 30 * 50; // EEG contribution (0-50)
    fatigue += _currentState == UserState.tired ? 50 : 0;
    
    return fatigue.clamp(0, 100);
  }
}

/// Biometric sensor abstraction
class BiometricSensor {
  final String name;
  bool _running = false;
  Map<String, double> _lastReading = {};
  
  BiometricSensor(this.name);
  
  Future<void> start() async {
    print('[$name] Sensor starting...');
    _running = true;
    
    // Simulate sensor reading loop
    _simulateReadings();
  }
  
  void _simulateReadings() async {
    final random = Random();
    
    while (_running) {
      // Generate realistic simulated readings
      switch (name) {
        case 'HR':
          _lastReading = {'bpm': 60 + random.nextInt(40)};
          break;
        case 'GSR':
          _lastReading = {'conductance': 1.0 + random.nextDouble() * 5};
          break;
        case 'EEG':
          _lastReading = {
            'alpha': 10 + random.nextDouble() * 20,
            'beta': 10 + random.nextDouble() * 20,
            'theta': 5 + random.nextDouble() * 20,
            'gamma': 5 + random.nextDouble() * 10,
          };
          break;
        case 'SpO2':
          _lastReading = {'percent': 95 + random.nextInt(6)};
          break;
        case 'TEMP':
          _lastReading = {'celsius': 36.0 + random.nextDouble() * 1.5};
          break;
        default:
          _lastReading = {'value': random.nextDouble() * 100};
      }
      
      await Future.delayed(Duration(seconds: 1));
    }
  }
  
  double read() {
    if (_lastReading.isEmpty) return 0;
    return _lastReading.values.first;
  }
  
  Map<String, double> readAll() => Map.unmodifiable(_lastReading);
  
  void stop() {
    _running = false;
  }
}

/// Comprehensive biometric readings snapshot
class BiometricReadings {
  final double heartRate;
  final double gsr;
  final Map<String, double> eeg;
  final Map<String, double> eog;
  final Map<String, double> emg;
  final double spo2;
  final double temperature;
  final DateTime timestamp;
  
  BiometricReadings({
    required this.heartRate,
    required this.gsr,
    required this.eeg,
    required this.eog,
    required this.emg,
    required this.spo2,
    required this.temperature,
    required this.timestamp,
  });
}

/// User state enumeration
enum UserState {
  neutral,
  focused,
  creative,
  tired,
  stressed,
  alert,
  asleep,
}

/// Health Guardian - Detect medical anomalies
class HealthGuardian {
  int _alertCount = 0;
  final List<String> _alerts = [];
  
  Function(String)? onHealthAlert;
  
  bool _initialized = false;
  
  Future<void> initialize() async {
    print('[HealthGuardian] Initializing...');
    _initialized = true;
  }
  
  /// Check for health anomalies
  Future<void> checkAnomalies(BiometricReadings readings) async {
    if (!_initialized) return;
    
    // Check for arrhythmia
    if (readings.heartRate > 120 || readings.heartRate < 40) {
      _raiseAlert('Arrhythmia detected: HR ${readings.heartRate} bpm');
    }
    
    // Check for low SpO2
    if (readings.spo2 < 90) {
      _raiseAlert('Low blood oxygen: ${readings.spo2}%');
    }
    
    // Check for fever
    if (readings.temperature > 38.5) {
      _raiseAlert('Elevated temperature: ${readings.temperature}°C');
    }
    
    // Check for extreme stress
    if (readings.gsr > 8 && readings.heartRate > 110) {
      _raiseAlert('Extreme stress detected - consider taking a break');
    }
    
    // Check for dehydration signs
    if (readings.gsr < 0.5 && readings.heartRate > 90) {
      _raiseAlert('Possible dehydration - drink water');
    }
  }
  
  void _raiseAlert(String message) {
    _alertCount++;
    _alerts.add(message);
    
    print('[HealthAlert] $message');
    
    if (onHealthAlert != null) {
      onHealthAlert!(message);
    }
  }
  
  int get alertCount => _alertCount;
  List<String> get alerts => List.unmodifiable(_alerts);
}

/// Energy Optimizer - Align OS power with biological cycles
class EnergyOptimizer {
  int _optimizationCount = 0;
  
  bool _initialized = false;
  
  Future<void> initialize() async {
    print('[EnergyOptimizer] Initializing...');
    _initialized = true;
  }
  
  /// Optimize system energy based on biological state
  Future<void> optimize(BiometricReadings readings, UserState state) async {
    if (!_initialized) return;
    
    _optimizationCount++;
    
    // Adjust CPU/GPU performance based on user state
    switch (state) {
      case UserState.focused:
        // Max performance - user needs responsiveness
        await _setPerformanceMode(PerformanceMode.max);
        break;
        
      case UserState.tired:
        // Power saving - extend battery, simplify UI
        await _setPerformanceMode(PerformanceMode.economy);
        break;
        
      case UserState.stressed:
        // Balanced - don't add thermal stress
        await _setPerformanceMode(PerformanceMode.balanced);
        break;
        
      default:
        await _setPerformanceMode(PerformanceMode.adaptive);
    }
    
    // Charge optimization based on circadian rhythm
    final hour = DateTime.now().hour;
    if (hour >= 23 || hour <= 6) {
      // Night time - slow charge to preserve battery health
      await _setChargingMode(ChargingMode.slow);
    } else {
      await _setChargingMode(ChargingMode.fast);
    }
  }
  
  Future<void> _setPerformanceMode(PerformanceMode mode) async {
    // In production: signal to power management
    print('[Energy] Performance mode: $mode');
  }
  
  Future<void> _setChargingMode(ChargingMode mode) async {
    // In production: signal to charging controller
    print('[Energy] Charging mode: $mode');
  }
  
  int get optimizationCount => _optimizationCount;
}

enum PerformanceMode {
  max,
  balanced,
  economy,
  adaptive,
}

enum ChargingMode {
  fast,
  slow,
  trickle,
  pause,
}

/// Biological integration statistics
class BioStats {
  final UserState currentState;
  final Duration stateDuration;
  final double heartRate;
  final double gsr;
  final double stressLevel;
  final double fatigueLevel;
  final int healthAlerts;
  final int energyOptimizations;
  
  BioStats({
    required this.currentState,
    required this.stateDuration,
    required this.heartRate,
    required this.gsr,
    required this.stressLevel,
    required this.fatigueLevel,
    required this.healthAlerts,
    required this.energyOptimizations,
  });
  
  @override
  String toString() {
    return '''
Biological Integration Statistics:
  Current State: $currentState (${_formatDuration(stateDuration)})
  Heart Rate: ${heartRate.toStringAsFixed(0)} bpm
  GSR: ${gsr.toStringAsFixed(2)} μS
  Stress Level: ${stressLevel.toStringAsFixed(1)}%
  Fatigue Level: ${fatigueLevel.toStringAsFixed(1)}%
  Health Alerts: $healthAlerts
  Energy Optimizations: $energyOptimizations
''';
  }
  
  String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}s';
    if (d.inHours < 1) return '${d.inMinutes}m';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
}

/// Example usage
void main() async {
  print('╔════════════════════════════════════════════════════════╗');
  print('║     OMNILINUX V2.0 - BIOLOGICAL INTEGRATION            ║');
  print('║     OS as Living Extension of Biology                  ║');
  print('╚════════════════════════════════════════════════════════╝');
  
  final bio = BiologicalIntegration();
  
  await bio.initialize();
  
  // Set up state change callback
  bio.onStateChanged = (state) {
    print('\n[Callback] User is now: $state');
    
    switch (state) {
      case UserState.focused:
        print('  → Maximizing performance, minimizing distractions');
        break;
      case UserState.tired:
        print('  → Simplifying UI, suggesting break');
        break;
      case UserState.stressed:
        print('  → Pausing notifications, playing calm audio');
        break;
      case UserState.creative:
        print('  → Enabling brainstorming mode');
        break;
    }
  };
  
  // Let it run for a bit to detect states
  print('\n[Bio] Monitoring biometric state...\n');
  
  // Simulate running for 5 seconds
  await Future.delayed(Duration(seconds: 5));
  
  // Print statistics
  print('\n${bio.getStatistics()}');
  
  print('[Bio] Biological integration operational.');
}
