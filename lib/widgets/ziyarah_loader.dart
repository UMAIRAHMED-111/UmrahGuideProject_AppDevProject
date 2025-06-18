import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class ZiyarahLoader extends StatefulWidget {
  final String? message;
  const ZiyarahLoader({super.key, this.message});

  @override
  State<ZiyarahLoader> createState() => _ZiyarahLoaderState();
}

class _ZiyarahLoaderState extends State<ZiyarahLoader>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _ringController;
  late final AnimationController _shimmerController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3D2E),
      body: Stack(
        children: [
          const Positioned.fill(child: _AnimatedDots()),

          // Centered Loader Panel
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Orbiting logo and pulse
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _ringController,
                            builder: (_, __) {
                              return Transform.rotate(
                                angle: _ringController.value * 2 * pi,
                                child: CustomPaint(
                                  painter: _OrbitingRingPainter(),
                                  size: const Size(80, 80),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _pulse,
                            builder:
                                (_, __) => Transform.scale(
                                  scale: _pulse.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF32D27F,
                                          ).withOpacity(0.45),
                                          blurRadius: 32,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      if (widget.message != null)
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (_, __) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: const [
                                    Colors.white,
                                    Color(0xFF32D27F),
                                    Colors.white,
                                  ],
                                  stops: const [0.3, 0.5, 0.7],
                                  begin: Alignment(
                                    -1 + 2 * _shimmerController.value,
                                    0,
                                  ),
                                  end: const Alignment(1, 0),
                                ).createShader(bounds);
                              },
                              child: Text(
                                widget.message!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitingRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..shader = SweepGradient(
            colors: [
              const Color(0xFF32D27F).withOpacity(0.0),
              const Color(0xFF32D27F).withOpacity(0.5),
              const Color(0xFF32D27F),
            ],
            startAngle: 0,
            endAngle: 2 * pi,
          ).createShader(
            Rect.fromCircle(
              center: size.center(Offset.zero),
              radius: size.width / 2,
            ),
          );

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      0,
      2 * pi,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots({super.key});
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
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
      builder:
          (_, __) =>
              CustomPaint(painter: _DotsPainter(progress: _controller.value)),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final double progress;
  _DotsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF32D27F).withOpacity(0.05)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i + sin(progress * 2 * pi + i) * 10;
      final y = (size.height / 20) * i + cos(progress * 2 * pi + i) * 10;
      canvas.drawCircle(Offset(x, y), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
