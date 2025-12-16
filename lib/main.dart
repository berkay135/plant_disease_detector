import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_disease_detector/src/core/router/app_router.dart';
import 'package:plant_disease_detector/src/core/theme/app_theme.dart';
import 'package:plant_disease_detector/src/core/theme/theme_provider.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/diagnosis_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load saved diagnosis history
  await DiagnosisHistory().loadHistory();
  
  runApp(const ProviderScope(child: PlantDiseaseDetectorApp()));
}

class PlantDiseaseDetectorApp extends ConsumerWidget {
  const PlantDiseaseDetectorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Plant Disease Detector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
