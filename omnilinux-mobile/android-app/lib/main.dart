/// OMNILINUX MOBILE - Main Entry Point
/// 
/// Phase 1: Core Engine
/// Milestone: Cold boot to Bash in <3 seconds, idle RAM <150MB

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lib/core/linux_engine.dart';
import 'lib/governor/ai_governor.dart';
import 'lib/ui/morphos_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AI Governor first (predictive optimization)
  await AIGovernor.instance.initialize();
  
  // Pre-load essential services based on prediction
  final predictedServices = AIGovernor.instance.predictNeededServices();
  
  // Initialize Linux Engine with predicted services
  await LinuxEngine.instance.initialize(predictedServices: predictedServices);
  
  // Enable immersive mode for full-screen experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const OmnilinuxMobileApp());
}
