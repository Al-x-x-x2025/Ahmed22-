import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF15161E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OfflineGemini',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Force dark theme
      home: const AssistantHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}