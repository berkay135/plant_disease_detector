import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plant_disease_detector/src/core/router/app_router.dart';
import 'package:plant_disease_detector/src/core/theme/app_theme.dart';
import 'package:plant_disease_detector/src/core/theme/theme_provider.dart';
import 'package:plant_disease_detector/src/core/storage/local_storage_service.dart';
import 'package:plant_disease_detector/src/core/supabase/supabase_config.dart';
import 'package:plant_disease_detector/src/core/services/notification_service.dart';
import 'package:plant_disease_detector/src/core/services/image_cache_service.dart';
import 'package:plant_disease_detector/src/core/services/plant_ai_service.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/diagnosis_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize locale data for intl package
  await initializeDateFormatting('tr', null);
  
  // Initialize local storage (Hive)
  await LocalStorageService.initialize();
  
  // Initialize image cache service
  await ImageCacheService().initialize();
  
  // Initialize notification service
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  
  // Initialize Plant AI service (Gemini)
  PlantAIService.instance.initialize(SupabaseConfig.geminiApiKey);
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  // Load saved diagnosis history (legacy - will migrate to Hive)
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
