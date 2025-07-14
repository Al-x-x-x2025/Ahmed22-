
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isListening = false;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _lastRecognizedText = '';
  
  // Wake word detection
  static const String _wakeWord = 'أسطورة';
  bool _wakeWordDetected = false;
  Timer? _listeningTimer;
  
  // Callbacks
  Function()? onWakeWordDetected;
  Function(String)? onCommandReceived;
  Function(bool)? onListeningStateChanged;
  
  // Getters
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  String get lastRecognizedText => _lastRecognizedText;
  
  Future<void> initialize() async {
    try {
      // Request microphone permission
      final microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted) {
        throw Exception('Microphone permission denied');
      }
      
      // Initialize speech recognition
      final speechAvailable = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );
      
      if (!speechAvailable) {
        throw Exception('Speech recognition not available');
      }
      
      // Initialize TTS
      await _tts.setLanguage('ar-SA'); // Arabic language
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      // Set TTS callbacks
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });
      
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      _tts.setErrorHandler((message) {
        _isSpeaking = false;
        if (kDebugMode) {
          print('TTS Error: $message');
        }
      });
      
      _isInitialized = true;
      
    } catch (e) {
      if (kDebugMode) {
        print('Voice service initialization error: $e');
      }
      rethrow;
    }
  }
  
  Future<void> startContinuousListening() async {
    if (!_isInitialized) {
      throw Exception('Voice service not initialized');
    }
    
    _startListening();
  }
  
  Future<void> _startListening() async {
    if (_isListening || _isSpeaking) return;
    
    try {
      _isListening = true;
      onListeningStateChanged?.call(true);
      
      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'ar-SA',
        listenMode: ListenMode.dictation,
      );
      
      // Set timeout for continuous listening
      _listeningTimer = Timer(const Duration(seconds: 15), () {
        _stopListening();
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Error starting speech recognition: $e');
      }
      _isListening = false;
      onListeningStateChanged?.call(false);
      
      // Restart listening after error
      Future.delayed(const Duration(seconds: 2), () {
        _startListening();
      });
    }
  }
  
  Future<void> _stopListening() async {
    if (!_isListening) return;
    
    _listeningTimer?.cancel();
    await _speech.stop();
    _isListening = false;
    onListeningStateChanged?.call(false);
    
    // Restart continuous listening after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      _startListening();
    });
  }
  
  void _onSpeechResult(result) {
    final recognizedText = result.recognizedWords.toLowerCase();
    _lastRecognizedText = recognizedText;
    
    if (kDebugMode) {
      print('Recognized: $recognizedText');
    }
    
    // Check for wake word
    if (recognizedText.contains(_wakeWord) && !_wakeWordDetected) {
      _wakeWordDetected = true;
      onWakeWordDetected?.call();
      
      // Extract command after wake word
      final wakeWordIndex = recognizedText.indexOf(_wakeWord);
      if (wakeWordIndex != -1) {
        final commandText = recognizedText.substring(wakeWordIndex + _wakeWord.length).trim();
        if (commandText.isNotEmpty) {
          onCommandReceived?.call(commandText);
        }
      }
      
      // Reset wake word detection after processing
      Future.delayed(const Duration(seconds: 5), () {
        _wakeWordDetected = false;
      });
    }
    
    // If wake word was detected previously, treat subsequent speech as command
    if (_wakeWordDetected && !recognizedText.contains(_wakeWord)) {
      onCommandReceived?.call(recognizedText);
    }
  }
  
  void _onSpeechError(error) {
    if (kDebugMode) {
      print('Speech recognition error: $error');
    }
    
    _isListening = false;
    onListeningStateChanged?.call(false);
    
    // Restart listening after error
    Future.delayed(const Duration(seconds: 2), () {
      _startListening();
    });
  }
  
  void _onSpeechStatus(status) {
    if (kDebugMode) {
      print('Speech status: $status');
    }
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      onListeningStateChanged?.call(false);
      
      // Restart continuous listening
      Future.delayed(const Duration(milliseconds: 500), () {
        _startListening();
      });
    }
  }
  
  Future<void> speak(String text) async {
    if (!_isInitialized || text.isEmpty) return;
    
    try {
      // Stop current listening while speaking
      if (_isListening) {
        await _speech.stop();
      }
      
      await _tts.speak(text);
      
      // Resume listening after speaking
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isListening) {
          _startListening();
        }
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('TTS error: $e');
      }
    }
  }
  
  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
  }
  
  Future<void> dispose() async {
    _listeningTimer?.cancel();
    await _speech.stop();
    await _tts.stop();
  }
}