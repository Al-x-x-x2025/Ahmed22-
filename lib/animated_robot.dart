import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedRobot extends StatefulWidget {
  final AnimationController glowController;
  final bool isListening;
  final bool isProcessing;
  final double size;

  const AnimatedRobot({
    super.key,
    required this.glowController,
    required this.isListening,
    required this.isProcessing,
    this.size = 200,
  });

  @override
  State<AnimatedRobot> createState() => _AnimatedRobotState();
}

class _AnimatedRobotState extends State<AnimatedRobot> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _mouthController;
  late AnimationController _headController;
  
  @override
  void initState() {
    super.initState();
    
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _mouthController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _headController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _startBlinking();
    _startHeadMovement();
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 2000 + (DateTime.now().millisecondsSinceEpoch % 3000)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse();
          _startBlinking();
        });
      }
    });
  }

  void _startHeadMovement() {
    _headController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AnimatedRobot oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _mouthController.repeat(reverse: true);
      } else {
        _mouthController.stop();
        _mouthController.reset();
      }
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _mouthController.dispose();
    _headController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.glowController,
          _blinkController,
          _mouthController,
          _headController,
        ]),
        builder: (context, child) {
          return Transform.rotate(
            angle: (_headController.value - 0.5) * 0.1,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                      0.3 * widget.glowController.value,
                    ),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: RobotPainter(
                  glowIntensity: widget.glowController.value,
                  blinkValue: _blinkController.value,
                  mouthValue: _mouthController.value,
                  isListening: widget.isListening,
                  isProcessing: widget.isProcessing,
                  primaryColor: Theme.of(context).colorScheme.primary,
                  secondaryColor: Theme.of(context).colorScheme.secondary,
                  tertiaryColor: Theme.of(context).colorScheme.tertiary,
                  surfaceColor: Theme.of(context).colorScheme.surface,
                ),
                size: Size(widget.size, widget.size),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RobotPainter extends CustomPainter {
  final double glowIntensity;
  final double blinkValue;
  final double mouthValue;
  final bool isListening;
  final bool isProcessing;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color surfaceColor;

  RobotPainter({
    required this.glowIntensity,
    required this.blinkValue,
    required this.mouthValue,
    required this.isListening,
    required this.isProcessing,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Robot head (main circle)
    final headPaint = Paint()
      ..color = surfaceColor.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final headBorderPaint = Paint()
      ..color = primaryColor.withOpacity(0.3 + 0.4 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, radius * 0.8, headPaint);
    canvas.drawCircle(center, radius * 0.8, headBorderPaint);
    
    // Eyes
    final eyeColor = isListening ? secondaryColor : (isProcessing ? tertiaryColor : primaryColor);
    final eyePaint = Paint()
      ..color = eyeColor.withOpacity(0.8 + 0.2 * glowIntensity)
      ..style = PaintingStyle.fill;
    
    final eyeGlowPaint = Paint()
      ..color = eyeColor.withOpacity(0.3 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    final leftEyeCenter = Offset(center.dx - radius * 0.3, center.dy - radius * 0.2);
    final rightEyeCenter = Offset(center.dx + radius * 0.3, center.dy - radius * 0.2);
    final eyeRadius = radius * 0.15;
    final eyeHeight = eyeRadius * (1 - blinkValue);
    
    // Eye glow effect
    canvas.drawCircle(leftEyeCenter, eyeRadius + 5, eyeGlowPaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius + 5, eyeGlowPaint);
    
    // Eyes (ellipse for blinking effect)
    canvas.drawOval(
      Rect.fromCenter(
        center: leftEyeCenter,
        width: eyeRadius * 2,
        height: eyeHeight * 2,
      ),
      eyePaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: rightEyeCenter,
        width: eyeRadius * 2,
        height: eyeHeight * 2,
      ),
      eyePaint,
    );
    
    // Eye pupils
    if (blinkValue < 0.8) {
      final pupilPaint = Paint()
        ..color = surfaceColor
        ..style = PaintingStyle.fill;
      
      final pupilRadius = eyeRadius * 0.3;
      canvas.drawCircle(leftEyeCenter, pupilRadius, pupilPaint);
      canvas.drawCircle(rightEyeCenter, pupilRadius, pupilPaint);
    }
    
    // Mouth
    final mouthCenter = Offset(center.dx, center.dy + radius * 0.3);
    final mouthPaint = Paint()
      ..color = isListening ? secondaryColor : primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    if (isListening) {
      // Animated mouth when listening
      final mouthWidth = radius * 0.4 * (1 + mouthValue * 0.3);
      final mouthHeight = radius * 0.1 * (1 + mouthValue * 0.5);
      
      canvas.drawOval(
        Rect.fromCenter(
          center: mouthCenter,
          width: mouthWidth,
          height: mouthHeight,
        ),
        mouthPaint,
      );
    } else {
      // Simple line mouth
      final mouthStart = Offset(mouthCenter.dx - radius * 0.2, mouthCenter.dy);
      final mouthEnd = Offset(mouthCenter.dx + radius * 0.2, mouthCenter.dy);
      canvas.drawLine(mouthStart, mouthEnd, mouthPaint);
    }
    
    // Antenna
    final antennaPaint = Paint()
      ..color = primaryColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final antennaStart = Offset(center.dx, center.dy - radius * 0.8);
    final antennaEnd = Offset(center.dx, center.dy - radius * 1.1);
    canvas.drawLine(antennaStart, antennaEnd, antennaPaint);
    
    // Antenna tip
    final antennaTipPaint = Paint()
      ..color = isListening ? secondaryColor : primaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(antennaEnd, radius * 0.05, antennaTipPaint);
    
    // Side details
    final detailPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    // Left side detail
    canvas.drawCircle(
      Offset(center.dx - radius * 0.7, center.dy),
      radius * 0.08,
      detailPaint,
    );
    
    // Right side detail
    canvas.drawCircle(
      Offset(center.dx + radius * 0.7, center.dy),
      radius * 0.08,
      detailPaint,
    );
    
    // Processing indicator
    if (isProcessing) {
      final processingPaint = Paint()
        ..color = tertiaryColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      final processingRadius = radius * 0.9;
      canvas.drawArc(
        Rect.fromCenter(center: center, width: processingRadius * 2, height: processingRadius * 2),
        -1.5708, // Start from top
        1.5708 * mouthValue * 2, // Arc length based on animation
        false,
        processingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}