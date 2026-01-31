import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/app_colors.dart';

class RadarScan extends StatefulWidget {
  final double size;
  final Color color;

  const RadarScan({
    super.key,
    this.size = 100,
    this.color = AppColors.primary,
  });

  @override
  State<RadarScan> createState() => _RadarScanState();
}

class _RadarScanState extends State<RadarScan> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _RadarPainter(_controller, widget.color),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RadarPainter(this.animation, this.color) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // 1. Draw concentric circles (Grid)
    final gridPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius * 0.3, gridPaint);
    canvas.drawCircle(center, radius * 0.6, gridPaint);
    canvas.drawCircle(center, radius * 0.9, gridPaint);
    
    // 2. Linear Scan Line (Grid crosshairs)
    canvas.drawLine(
      Offset(center.dx - radius, center.dy), 
      Offset(center.dx + radius, center.dy), 
      gridPaint
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius), 
      Offset(center.dx, center.dy + radius), 
      gridPaint
    );

    // 3. Rotating Scanner
    final scanPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.1),
          color.withOpacity(0.5), // Leading edge
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: GradientRotation(animation.value * 2 * math.pi - math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.9, scanPaint);

    // 4. Blips (Random dots appearing)
    // We deterministically generate blips based on animation value to look random but stable
    final t = animation.value * 100; // Time seed
    if ((t % 20).toInt() > 10) {
       _drawBlip(canvas, center, radius, 45, color);
    }
    if ((t % 35).toInt() > 25) {
       _drawBlip(canvas, center, radius, 160, color);
    }
  }

  void _drawBlip(Canvas canvas, Offset center, double radius, double angleDeg, Color color) {
    final angle = angleDeg * math.pi / 180;
    final dist = radius * 0.7;
    final offset = Offset(
      center.dx + dist * math.cos(angle),
      center.dy + dist * math.sin(angle),
    );
    
    canvas.drawCircle(offset, 3, Paint()..color = color.withOpacity(0.8));
    canvas.drawCircle(offset, 6, Paint()..color = color.withOpacity(0.3));
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => true;
}
