import 'dart:math';

import 'package:flutter/material.dart';

class WaterLevel extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color waveColor;
  final double level;

  const WaterLevel({
    super.key,
    required this.size,
    this.duration = const Duration(milliseconds: 1500),
    this.waveColor = const Color(0xff3B6ABA),
    required this.level,
  });

  @override
  _WaterLevelState createState() => _WaterLevelState();
}

class _WaterLevelState extends State<WaterLevel> with TickerProviderStateMixin {
  late AnimationController waveController;
  late Animation<double> waveAnimation;

  @override
  void initState() {
    super.initState();

    waveController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    waveAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: waveController,
        curve: Curves.linear,
      ),
    )..addListener(() {
        setState(() {});
      });

    waveController.repeat();
  }

  @override
  void dispose() {
    waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipOval(
        child: CustomPaint(
          painter: WavePainter(
            waveAnimation.value,
            waveColor: widget.waveColor,
            waterLevel: widget.level,
          ),
          child: SizedBox(
            height: widget.size,
            width: widget.size,
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveValue;
  final Color waveColor;
  final double waterLevel;

  WavePainter(this.waveValue,
      {required this.waveColor, required this.waterLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final waterHeight = size.height * (1 - waterLevel);
    const amplitude = 10.0;
    const frequency = 0.03;

    final path = Path()..moveTo(0, waterHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = waterHeight + amplitude * sin(frequency * x + waveValue);
      path.lineTo(x, y);
    }

    // Close the path to fill the water area
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.waveValue != waveValue ||
        oldDelegate.waterLevel != waterLevel ||
        oldDelegate.waveColor != waveColor;
  }
}
