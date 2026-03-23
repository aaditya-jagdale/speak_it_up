import 'package:speak_it_up/shared/services/settings_service.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:translator/translator.dart';

class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final TextToSpeech _tts = TextToSpeech();
  final GoogleTranslator _translator = GoogleTranslator();

  Future<void> announceTopicAsync(String topic) async {
    final settings = SettingsService.instance;
    if (!settings.soundEnabled || topic.isEmpty) return;

    final languageCode = settings.languageCode;

    try {
      String textToSpeak = topic;

      if (!languageCode.toLowerCase().startsWith('en')) {
        final String shortCode = languageCode.split('-').first.toLowerCase();
        final translation = await _translator.translate(
          topic,
          from: 'en',
          to: shortCode,
        );
        textToSpeak = translation.text;
      }

      await _tts.setLanguage(languageCode);
      await _tts.speak(textToSpeak);
    } catch (_) {}
  }

  void stop() {
    _tts.stop();
  }
}
