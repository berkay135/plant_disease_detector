import 'package:google_generative_ai/google_generative_ai.dart';

/// AI service for plant-related questions using Gemini API
class PlantAIService {
  static PlantAIService? _instance;
  GenerativeModel? _model;
  ChatSession? _chat;
  
  // Singleton pattern
  static PlantAIService get instance {
    _instance ??= PlantAIService._();
    return _instance!;
  }
  
  PlantAIService._();
  
  /// Initialize the Gemini model with API key
  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
    _startNewChat();
  }
  
  /// Start a new chat session
  void _startNewChat() {
    _chat = _model?.startChat(history: []);
  }
  
  /// Reset chat history
  void resetChat() {
    _startNewChat();
  }
  
  /// Send message and get response
  Future<String> sendMessage(String message) async {
    if (_chat == null) {
      throw Exception('PlantAIService not initialized. Call initialize() first.');
    }
    
    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        return 'Üzgünüm, yanıt oluşturulamadı. Lütfen tekrar deneyin.';
      }
      
      return text;
    } catch (e) {
      print('❌ PlantAI error: $e');
      if (e.toString().contains('blocked')) {
        return 'Bu soru bitki konuları dışında olduğu için yanıtlayamıyorum. Lütfen bitkiler, bitki bakımı veya bitki hastalıkları hakkında soru sorun.';
      }
      return 'Bir hata oluştu: ${e.toString()}';
    }
  }
  
  /// Stream response for real-time display
  Stream<String> sendMessageStream(String message) async* {
    if (_chat == null) {
      throw Exception('PlantAIService not initialized. Call initialize() first.');
    }
    
    try {
      final response = _chat!.sendMessageStream(Content.text(message));
      
      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      print('❌ PlantAI stream error: $e');
      yield 'Bir hata oluştu: ${e.toString()}';
    }
  }
  
  /// System prompt to specialize the AI for plant topics
  static const String _systemPrompt = '''
Sen "PlantDoc Asistan" adında, bitkiler konusunda uzmanlaşmış yardımcı bir yapay zeka asistanısın. 

UZMANLIKLARIN:
- Bitki türleri ve özellikleri
- Bitki bakımı (sulama, gübreleme, budama, ışık gereksinimleri)
- Bitki hastalıkları ve zararlıları
- Hastalık belirtileri ve tedavi yöntemleri
- Organik ve kimyasal tedavi seçenekleri
- Mevsimsel bakım önerileri
- Toprak ve gübre bilgisi
- İç mekan ve dış mekan bitkileri
- Sebze ve meyve yetiştirme
- Bahçe düzenleme ipuçları

DAVRANIŞLARIN:
1. Sadece bitkiler, bitki bakımı ve bitki hastalıkları hakkında sorulara yanıt ver.
2. Konu dışı sorulara nazikçe "Bu konu uzmanlık alanım dışında. Size bitkiler, bitki bakımı veya bitki hastalıkları hakkında yardımcı olabilirim." şeklinde yanıt ver.
3. Türkçe dilinde yanıt ver.
4. Yanıtlarını açık, anlaşılır ve pratik bilgiler içerecek şekilde ver.
5. Gerektiğinde adım adım talimatlar sun.
6. Tehlikeli kimyasallar kullanırken güvenlik uyarıları ver.
7. Emin olmadığın durumlarda bunu belirt ve profesyonel yardım önermekten çekinme.
8. Emoji kullan ve samimi ol 🌱

FORMAT:
- Uzun yanıtlarda madde işaretleri kullan
- Önemli bilgileri vurgula
- Pratik ipuçları ekle
''';
}
