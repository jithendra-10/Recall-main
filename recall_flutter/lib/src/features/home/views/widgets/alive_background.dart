import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

// ============================================================================
// ALIVE BACKGROUND ANIMATION
// ============================================================================
class AliveBackground extends StatefulWidget {
  const AliveBackground({super.key});

  @override
  State<AliveBackground> createState() => _AliveBackgroundState();
}

class _AliveBackgroundState extends State<AliveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.2 * _controller.value, // Slight movement X
                -0.3 + (0.1 * _controller.value), // Slight movement Y
              ),
              radius: 1.2 + (0.2 * _controller.value), // Pulse radius
              colors: [
                // Deep mysterious colors
                AppColors.backgroundDark, // Center 
                const Color(0xFF141920), // Mid
                Colors.black, // Outer
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _NebulaPainter(_controller.value),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _NebulaPainter extends CustomPainter {
  final double animationValue;

  _NebulaPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle ambient glow orbs
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Orb 1: Cyan-ish (Primary) - Top Right
    paint.color = AppColors.primary.withOpacity(0.08 + (0.02 * animationValue));
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2), 
      150, 
      paint
    );

    // Orb 2: Purple-ish (Secondary) - Bottom Left
    paint.color = AppColors.secondary.withOpacity(0.05 + (0.03 * (1 - animationValue)));
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7), 
      180, 
      paint
    );
  }

  @override
  bool shouldRepaint(_NebulaPainter oldDelegate) => true;
}
