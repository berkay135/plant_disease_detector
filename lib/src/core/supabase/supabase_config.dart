import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration
/// 
/// API keys are loaded from .env file for security.
/// See .env.example for the required format.
class SupabaseConfig {
  /// Your Supabase project URL
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  
  /// Your Supabase anonymous/public key
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  /// Storage bucket name for diagnosis images
  static const String storageBucket = 'diagnosis-images';
  
  /// Google OAuth Client ID for Android
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  
  /// Google Gemini AI API Key
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
