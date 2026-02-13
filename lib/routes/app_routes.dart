import 'package:flutter/material.dart';
import '../presentation/camera_screen/camera_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/emergency_mode_flow/emergency_mode_flow.dart';
import '../presentation/onboarding_pairing_flow/onboarding_pairing_flow.dart';
import '../presentation/map_screen/map_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String camera = '/camera-screen';
  static const String settings = '/settings-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String emergencyModeFlow = '/emergency-mode-flow';
  static const String onboardingPairingFlow = '/onboarding-pairing-flow';
  static const String map = '/map-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingPairingFlow(),
    camera: (context) => const CameraScreen(),
    settings: (context) => const SettingsScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    emergencyModeFlow: (context) => const EmergencyModeFlow(),
    onboardingPairingFlow: (context) => const OnboardingPairingFlow(),
    map: (context) => const MapScreen(),
    // TODO: Add your other routes here
  };
}
