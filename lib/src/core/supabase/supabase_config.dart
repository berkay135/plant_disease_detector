/// Supabase configuration
/// 
/// Replace these values with your Supabase project credentials.
/// You can find them in: Supabase Dashboard > Project Settings > API
class SupabaseConfig {
  /// Your Supabase project URL
  /// Example: 'https://xyzcompany.supabase.co'
  static const String supabaseUrl = 'https://mzxhkwxgggdsdbqhhxqf.supabase.co';
  
  /// Your Supabase anonymous/public key
  /// This key is safe to use in client apps
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16eGhrd3hnZ2dkc2RicWhoeHFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MDcwMTAsImV4cCI6MjA4MDA4MzAxMH0.X4HL6PELN77uXiaC0CTDvlnzzVnjVUFVmcKXgwEjViI';
  
  /// Storage bucket name for diagnosis images
  static const String storageBucket = 'diagnosis-images';
  
  /// Google OAuth Client ID for Android
  /// Get this from Google Cloud Console > Credentials > OAuth 2.0 Client IDs
  /// Use the Web application client ID (not Android)
  static const String googleClientId = '278132602020-rk37g7spj4hism6n0hhu3n1mn2vomo48.apps.googleusercontent.com';
  
  /// Google Gemini AI API Key
  /// Get this from Google AI Studio: https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyCE7A6KC4U9aOHlcvjKV7FAZ7Jh8zR5b78';
}
