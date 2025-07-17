import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  void init() async {
    await _speech.initialize();
    await _tts.setLanguage("ar"); // لغة عربية
    await _tts.setSpeechRate(0.4); // سرعة النطق
  }

  void dispose() {
    _speech.stop();
    _tts.stop();
  }

  void listen({required Function(String) onResult}) async {
    if (_isListening) return;
    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          onResult(result.recognizedWords);
        }
      },
    );
  }

  void speak(String text) {
    _tts.speak(text);
  }

  void handleCommand(String command, Function(String) onReply) {
    String reply;

    if (command.contains("الساعة")) {
      final now = DateTime.now();
      reply = "الساعة الآن هي ${now.hour}:${now.minute}";
    } else if (command.contains("اسمك")) {
      reply = "أنا المساعد الذكي أسطورة، تحت أمرك!";
    } else if (command.contains("افتح واتساب")) {
      reply = "لا أستطيع فتح التطبيقات من الويب، لكن يمكنني فعل ذلك من التطبيق.";
    } else {
      reply = "لم أفهم، هل يمكنك إعادة الصياغة؟";
    }

    onReply(reply);
    speak(reply); // 🔊 نطق الرد
  }
}
