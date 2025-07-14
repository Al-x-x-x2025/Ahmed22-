import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class ListeningIndicator extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final Color? color;

  const ListeningIndicator({
    super.key,
    required this.controller,
    this.size = 280,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? Theme.of(context).colorScheme.secondary;
    
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              Container(
                width: size * (0.8 + 0.2 * controller.value),
                height: size * (0.8 + 0.2 * controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: indicatorColor.withOpacity(0.3 * (1 - controller.value)),
                    width: 2,
                  ),
                ),
              ),
              
              // Middle pulsing ring
              Container(
                width: size * (0.6 + 0.15 * controller.value),
                height: size * (0.6 + 0.15 * controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: indicatorColor.withOpacity(0.5 * (1 - controller.value)),
                    width: 1.5,
                  ),
                ),
              ),
              
              // Inner pulsing ring
              Container(
                width: size * (0.4 + 0.1 * controller.value),
                height: size * (0.4 + 0.1 * controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: indicatorColor.withOpacity(0.7 * (1 - controller.value)),
                    width: 1,
                  ),
                ),
              ),
              
              // Animated dots around the circle
              ...List.generate(8, (index) {
                final angle = (index / 8) * 2 * 3.14159;
                final dotRadius = size * 0.35;
                final dotX = dotRadius * math.cos(angle);
                final dotY = dotRadius * math.sin(angle);
                
                return Transform.translate(
                  offset: Offset(dotX, dotY),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: indicatorColor.withOpacity(
                        0.3 + 0.7 * ((controller.value + index * 0.125) % 1),
                      ),
                    ),
                  ),
                );
              }),
              
              // Sound wave bars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (index) {
                  final barHeight = 20 + 15 * math.sin(
                    (controller.value * 6.28) + (index * 0.5),
                  ).abs();
                  
                  return Container(
                    width: 3,
                    height: barHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: indicatorColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
