import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../widgets/animated_robot.dart';
import '../widgets/listening_indicator.dart';
import '../widgets/voice_response_card.dart';
import '../services/voice_service.dart';
import '../services/app_launcher_service.dart';
import '../services/command_processor.dart';
import '../models/voice_command.dart';

class AssistantHomePage extends StatefulWidget {
  const AssistantHomePage({super.key});

  @override
  State<AssistantHomePage> createState() => _AssistantHomePageState();
}

class _AssistantHomePageState extends State<AssistantHomePage> with TickerProviderStateMixin {
  late VoiceService _voiceService;
  late AppLauncherService _appLauncherService;
  late CommandProcessor _commandProcessor;
  
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentResponse = '';
  String _lastCommand = '';
  bool _isInitialized = false;
  
  late AnimationController _glowController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _voiceService = VoiceService();
    _appLauncherService = AppLauncherService();
    _commandProcessor = CommandProcessor();
    
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _voiceService.initialize();
      await _appLauncherService.initialize();
      
      // Set up voice command callback
      _voiceService.onWakeWordDetected = _handleWakeWord;
      _voiceService.onCommandReceived = _handleCommand;
      _voiceService.onListeningStateChanged = _handleListeningState;
      
      setState(() {
        _isInitialized = true;
        _currentResponse = 'مرحباً! قل "أسطورة" للبدء';
      });
      
      // Start continuous listening
      await _voiceService.startContinuousListening();
      
    } catch (e) {
      setState(() {
        _currentResponse = 'خطأ في تهيئة الخدمات: $e';
      });
    }
  }

  void _handleWakeWord() {
    setState(() {
      _isListening = true;
      _currentResponse = 'أسمعك... ما هو طلبك؟';
    });
    _pulseController.repeat();
    _voiceService.speak(_currentResponse);
  }

  void _handleCommand(String command) async {
    setState(() {
      _isProcessing = true;
      _lastCommand = command;
    });
    
    try {
      final voiceCommand = _commandProcessor.processCommand(command);
      
      if (voiceCommand.isValid) {
        final success = await _appLauncherService.launchApp(voiceCommand.appName);
        
        if (success) {
          setState(() {
            _currentResponse = 'تم فتح ${voiceCommand.appName}';
          });
        } else {
          setState(() {
            _currentResponse = 'لم أتمكن من العثور على تطبيق ${voiceCommand.appName}';
          });
        }
      } else {
        setState(() {
          _currentResponse = 'لم أفهم الطلب. حاول مرة أخرى';
        });
      }
    } catch (e) {
      setState(() {
        _currentResponse = 'حدث خطأ في معالجة الطلب';
      });
    }
    
    _voiceService.speak(_currentResponse);
    
    setState(() {
      _isProcessing = false;
      _isListening = false;
    });
    
    _pulseController.stop();
    _pulseController.reset();
  }

  void _handleListeningState(bool isListening) {
    setState(() {
      _isListening = isListening;
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OfflineGemini',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'مساعدك الذكي الشخصي',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isInitialized 
                          ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                          : Theme.of(context).colorScheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isInitialized 
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isInitialized ? 'متصل' : 'غير متصل',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _isInitialized 
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Robot avatar with listening indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Listening indicator (outer ring)
                        if (_isListening)
                          ListeningIndicator(
                            controller: _pulseController,
                            size: 280,
                          ),
                        
                        // Robot avatar
                        AnimatedRobot(
                          glowController: _glowController,
                          isListening: _isListening,
                          isProcessing: _isProcessing,
                          size: 200,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Response card
                    VoiceResponseCard(
                      response: _currentResponse,
                      lastCommand: _lastCommand,
                      isProcessing: _isProcessing,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Status indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatusIndicator(
                          icon: Icons.mic,
                          label: 'الاستماع',
                          isActive: _isListening,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 32),
                        _StatusIndicator(
                          icon: Icons.psychology,
                          label: 'المعالجة',
                          isActive: _isProcessing,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 32),
                        _StatusIndicator(
                          icon: Icons.volume_up,
                          label: 'التحدث',
                          isActive: _voiceService.isSpeaking,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bottom instruction
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'قل "أسطورة" ثم اسم التطبيق',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'مثال: "أسطورة افتح واتساب" أو "أسطورة افتح المعرض"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;

  const _StatusIndicator({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.2) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color : color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? color : color.withOpacity(0.5),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isActive ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}