import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidBackgroundScreen extends StatelessWidget {
  final Widget child;
  final Color primaryColor;
  final Color accentColor;
  final AnimationController controller;

  const LiquidBackgroundScreen({
    Key? key,
    required this.child,
    required this.primaryColor,
    required this.accentColor,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: child,
        ),

        // Top wave decoration - subtly shows at the top of the screen
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 30,
            child: LiquidWave(
              color: primaryColor.withOpacity(0.1),
              height: 20,
              waveAmplitude: 5,
              waveFrequency: 1.5,
              duration: const Duration(seconds: 8),
            ),
          ),
        ),

        // Second wave, slightly offset
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 20,
            child: LiquidWave(
              color: accentColor.withOpacity(0.1),
              height: 12,
              waveAmplitude: 3,
              waveFrequency: 2.0,
              duration: const Duration(seconds: 6),
            ),
          ),
        ),
      ],
    );
  }
}
// Custom Liquid Wave Painter
class LiquidWavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final double height;
  final double waveAmplitude;
  final double waveFrequency;

  LiquidWavePainter({
    required this.animation,
    required this.color,
    required this.height,
    this.waveAmplitude = 20.0,
    this.waveFrequency = 1.6,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveWidth = size.width;

    // Start from bottom-left
    path.moveTo(0, size.height);

    // Create the wave pattern
    for (double i = 0; i < waveWidth; i++) {
      // Calculate y position with two sine waves for more natural look
      final y = math.sin((i / waveWidth * 2 * math.pi * waveFrequency) + animation.value * 2 * math.pi) *
          waveAmplitude * math.sin(animation.value * math.pi);

      final y2 = math.sin((i / waveWidth * 2 * math.pi * waveFrequency * 1.5) +
          animation.value * 2 * math.pi + math.pi / 4) * waveAmplitude * 0.5;

      path.lineTo(i, size.height - height + y + y2);
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidWavePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.color != color ||
        oldDelegate.height != height;
  }
}

// Widget that creates the liquid wave effect
class LiquidWave extends StatefulWidget {
  final Color color;
  final double height;
  final double waveAmplitude;
  final double waveFrequency;
  final Duration duration;

  const LiquidWave({
    Key? key,
    required this.color,
    required this.height,
    this.waveAmplitude = 20.0,
    this.waveFrequency = 1.6,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<LiquidWave> createState() => _LiquidWaveState();
}

class _LiquidWaveState extends State<LiquidWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
      width: double.infinity,
      height: widget.height,
      child: CustomPaint(
        painter: LiquidWavePainter(
          animation: _controller,
          color: widget.color,
          height: widget.height,
          waveAmplitude: widget.waveAmplitude,
          waveFrequency: widget.waveFrequency,
        ),
      ),
    );
  }
}

// Widget for a liquid-styled drawer header
class LiquidDrawerHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final Color primaryColor;
  final Color accentColor;

  const LiquidDrawerHeader({
    Key? key,
    required this.userName,
    required this.userRole,
    required this.primaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          color: primaryColor,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LiquidWave(
            color: accentColor.withOpacity(0.7),
            height: 70,
            waveAmplitude: 8,
            waveFrequency: 2.0,
            duration: const Duration(seconds: 5),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: LiquidWave(
            color: accentColor.withOpacity(0.5),
            height: 40,
            waveAmplitude: 5,
            waveFrequency: 1.5,
            duration: const Duration(seconds: 7),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Icon(
                Icons.account_circle,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Role: $userRole',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget for liquid-styled bottom sheet
class LiquidBottomSheet extends StatelessWidget {
  final Widget child;
  final Color primaryColor;
  final Color accentColor;

  const LiquidBottomSheet({
    Key? key,
    required this.child,
    required this.primaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base container for the bottom sheet
        Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top wave decoration
              SizedBox(
                height: 40,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Transform.rotate(
                        angle: math.pi,
                        child: LiquidWave(
                          color: primaryColor.withOpacity(0.1),
                          height: 25,
                          waveAmplitude: 4,
                          waveFrequency: 2.5,
                          duration: const Duration(seconds: 6),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Transform.rotate(
                        angle: math.pi,
                        child: LiquidWave(
                          color: accentColor.withOpacity(0.1),
                          height: 15,
                          waveAmplitude: 3,
                          waveFrequency: 3.0,
                          duration: const Duration(seconds: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actual content
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }
}