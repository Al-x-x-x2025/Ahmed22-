import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const OfflineGemini());
}

class OfflineGemini extends StatelessWidget {
  const OfflineGemini({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OfflineGemini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
