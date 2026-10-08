import 'package:flutter/material.dart';
import '../../features/main/view/main_screen.dart';
import '../../features/symptoms/view/symptom_screen.dart';
import '../../features/scanner/view/scanner_screen.dart';
import '../../features/analysis/view/analysis_screen.dart';
import '../../features/activity/view/activity_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String symptoms = '/symptoms';
  static const String scanner = '/scanner';
  static const String analysis = '/analysis';
  static const String activity = '/activity';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _fade(const MainScreen());
      case symptoms:
        return _fade(const SymptomScreen());
      case scanner:
        return _fade(const ScannerScreen());
      case analysis:
        final id = settings.arguments as int?;
        return _fade(AnalysisScreen(analysisId: id));
      case activity:
        return _fade(const ActivityScreen());
      default:
        return _fade(const MainScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );
}
