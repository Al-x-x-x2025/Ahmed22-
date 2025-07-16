import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

void main() {
  runApp(const OfflineGemini());
}

class OfflineGemini extends StatefulWidget {
  const OfflineGemini({Key? key}) : super(key: key);

  @override
  _OfflineGeminiState createState() => _OfflineGeminiState();
}

class _OfflineGeminiState extends State<OfflineGemini> {
  late stt.SpeechToText _speech;
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _text = 'قل "أسطورة" لبدء الأمر';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts.setLanguage("ar");
    _tts.setSpeechRate(0.8);
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('🟡 Status: $status'),
      onError: (error) => print('🔴 Error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;

            if (_text.toLowerCase().contains('أسطورة')) {
              _executeCommand(_text);
            }
          });
        },
        localeId: 'ar_SA', // اللغة العربية السعودية
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _speak(String msg) async {
    await _tts.speak(msg);
  }

  void _executeCommand(String command) {
    if (command.contains("واتساب")) {
      _speak("جاري فتح واتساب");
      _launchApp("com.whatsapp");
    } else if (command.contains("المعرض")) {
      _speak("جاري فتح المعرض");
      _launchApp("com.google.android.apps.photos");
    } else if (command.contains("الكاميرا")) {
      _speak("جاري فتح الكاميرا");
      _launchApp("com.android.camera");
    } else {
      _speak("لم أفهم الأمر");
    }
  }

  void _launchApp(String packageName) {
    final intent = AndroidIntent(
      action: 'action_view',
      package: packageName,
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('OfflineGemini'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _text,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                backgroundColor: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
