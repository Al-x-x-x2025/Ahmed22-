
import 'package:flutter/foundation.dart';
import '../models/voice_command.dart';
import '../utils/arabic_text_utils.dart';

class CommandProcessor {
  // Command patterns in Arabic
  static const List<String> _openCommands = [
    'افتح',
    'شغل',
    'فتح',
    'تشغيل',
    'open',
    'start',
    'launch',
    'run',
  ];
  
  static const List<String> _appCommands = [
    'تطبيق',
    'برنامج',
    'app',
    'application',
    'program',
  ];
  
  VoiceCommand processCommand(String command) {
    if (command.isEmpty) {
      return VoiceCommand.invalid('Empty command');
    }
    
    try {
      // Clean and normalize the command
      final cleanCommand = _cleanCommand(command);
      
      if (kDebugMode) {
        print('Processing command: $cleanCommand');
      }
      
      // Extract app name from command
      final appName = _extractAppName(cleanCommand);
      
      if (appName.isEmpty) {
        return VoiceCommand.invalid('No app name found in command');
      }
      
      // Create valid voice command
      return VoiceCommand(
        rawCommand: command,
        cleanCommand: cleanCommand,
        action: CommandAction.openApp,
        appName: appName,
        isValid: true,
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error processing command: $e');
      }
      return VoiceCommand.invalid('Error processing command: $e');
    }
  }
  
  String _cleanCommand(String command) {
    // Remove extra spaces and normalize
    String cleaned = command.trim().toLowerCase();
    
    // Remove common noise words
    final noiseWords = [
      'من فضلك',
      'لو سمحت',
      'please',
      'can you',
      'could you',
      'الرجاء',
      'أريد',
      'أريد أن',
      'I want',
      'I want to',
    ];
    
    for (final noise in noiseWords) {
      cleaned = cleaned.replaceAll(noise, '');
    }
    
    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }
  
  String _extractAppName(String command) {
    // Split command into words
    final words = command.split(' ');
    
    // Look for open commands
    bool foundOpenCommand = false;
    int openCommandIndex = -1;
    
    for (int i = 0; i < words.length; i++) {
      if (_openCommands.contains(words[i])) {
        foundOpenCommand = true;
        openCommandIndex = i;
        break;
      }
    }
    
    if (!foundOpenCommand) {
      // Maybe the command is just the app name
      final appName = ArabicTextUtils.getEnglishAppName(command);
      if (appName != command) {
        return appName;
      }
      return command;
    }
    
    // Extract app name after open command
    final appNameParts = <String>[];
    for (int i = openCommandIndex + 1; i < words.length; i++) {
      final word = words[i];
      
      // Skip app command words
      if (_appCommands.contains(word)) {
        continue;
      }
      
      appNameParts.add(word);
    }
    
    if (appNameParts.isEmpty) {
      return '';
    }
    
    final appName = appNameParts.join(' ');
    
    // Try to get English app name
    final englishName = ArabicTextUtils.getEnglishAppName(appName);
    
    if (kDebugMode) {
      print('Extracted app name: $appName -> $englishName');
    }
    
    return englishName;
  }
  
  List<String> getSuggestedCommands() {
    return [
      'أسطورة افتح واتساب',
      'أسطورة شغل فيسبوك',
      'أسطورة افتح المعرض',
      'أسطورة فتح الكاميرا',
      'أسطورة شغل يوتيوب',
      'أسطورة افتح الإعدادات',
      'أسطورة فتح الخرائط',
      'أسطورة شغل تلغرام',
      'أسطورة افتح انستغرام',
      'أسطورة فتح الهاتف',
    ];
  }
  
  bool isValidCommand(String command) {
    final processed = processCommand(command);
    return processed.isValid;
  }
}