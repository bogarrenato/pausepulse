import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'presentation/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await configureDependencies();
  
  runApp(const PausePulseApp());
}

class PausePulseApp extends StatelessWidget {
  const PausePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
