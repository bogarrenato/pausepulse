import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'presentation/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize dependency injection
    await configureDependencies();
  } catch (e) {
    // If dependency injection fails, continue with app but show error
    debugPrint('Dependency injection failed: $e');
  }
  
  runApp(const PausePulseApp());
}

class PausePulseApp extends StatelessWidget {
  const PausePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
