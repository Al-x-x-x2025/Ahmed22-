import 'package:flutter/material.dart';
import 'voice_service.dart';
import 'voice_response_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VoiceService voiceService = VoiceService();
  final List<Widget> messages = [];

  void _startListening() {
    voiceService.listen(
      onResult: (text) {
        if (!text.toLowerCase().startsWith("أسطورة")) return;
        final command = text.substring("أسطورة".length).trim();

        setState(() {
          messages.add(VoiceResponseCard(userText: command));
        });

        voiceService.handleCommand(command, (botReply) {
          setState(() {
            messages.add(VoiceResponseCard(botText: botReply));
          });
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    voiceService.init();
  }

  @override
  void dispose() {
    voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مساعد أسطورة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: messages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        child: const Icon(Icons.mic),
      ),
    );
  }
}
