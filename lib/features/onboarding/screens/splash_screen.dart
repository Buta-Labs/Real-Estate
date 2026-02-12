import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _pulseController;
  late AnimationController _loadingController;

  // Particle system
  final List<Particle> particles = [];
  final Random random = Random();
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Orb Float Animation
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Pulse Glow Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Initial Loading Progress
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _loadingController.forward().whenComplete(() {
      if (mounted) {
        context.go('/login');
      }
    });

    // Particle Animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 20; i++) {
      particles.add(
        Particle(
          position: Offset(
            random.nextDouble() * 400, // Screen width approx
            800 + random.nextDouble() * 200, // Start below screen
          ),
          speed: 0.5 + random.nextDouble() * 1.5,
          size: 2.0 + random.nextDouble() * 4.0,
          color: i % 2 == 0
              ? AppColors.primary.withValues(alpha: 0.2)
              : const Color(0xFFD4AF37).withValues(alpha: 0.2), // Gold accent
        ),
      );
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1a2e26), Color(0xFF10221c), Color(0xFF050b09)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Particle System
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: particles,
                    progress: _particleController.value,
                  ),
                  size: MediaQuery.of(context).size,
                );
              },
            ),

            // Ambient Light Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.backgroundDark.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Main Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Glass Orb
                _buildGlassOrb(),

                const SizedBox(height: 48),

                // Typography
                Text(
                  'ORRE',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 8,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'MMC',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                              foreground: Paint()
                                ..shader =
                                    const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        Color(0xFF059669), // Emerald 600
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 70),
                                    ),
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'OWNERSHIP • RIGHTS • REVENUE • EQUITY',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),

            // Loading Bar (Bottom)
            Positioned(
              bottom: 64,
              left: 48,
              right: 48,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'INITIALIZING ASSETS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'SECURE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _loadingController,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: _loadingController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassOrb() {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbController, _pulseController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glow
            Transform.translate(
              offset: Offset(0, -20 * sin(_orbController.value * 2 * pi)),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: 0.2 * _pulseController.value,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Glass Container
            Transform.translate(
              offset: Offset(0, -20 * sin(_orbController.value * 2 * pi)),
              child: Transform.rotate(
                angle: 2 * pi * 0.125, // 45 degrees
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Center(child: _buildInnerCore()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInnerCore() {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4AF37), Color(0xFF8A6E2F), Color(0xFF463611)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ), // Inner shadow simulation
        ],
      ),
      child: Stack(
        children: [
          // Shine effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: const [0.4, 0.5, 0.6],
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Symbol
          Center(
            child: Icon(
              Icons.layers, // Using layers icon as abstract symbol replacement
              color: AppColors.backgroundDark.withValues(alpha: 0.9),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  double speed;
  double size;
  Color color;

  Particle({
    required this.position,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Calculate animated position
      // Move upwards
      double dy = particle.position.dy - (progress * 100 * particle.speed);

      // Reset if off screen
      if (dy < -50) {
        dy = size.height + (dy % size.height);
      }

      // Simple loop using modulo for continuous effect simulation in this short snippet
      // For true continuous loop without jump, we'd need time-based delta.
      // Here we simulate by just letting them float up.

      // Actual implementation for continuous flow:
      // We update the dy based on the controller value which loops 0..1
      // But since we want them to float indefinitely, we can just use the controller to drive
      // a 'tick' and update state in the widget, OR use the value to offset.
      // A better approach for continuous loop is to update positions in a listener.
      // But for this static implementation, we'll just use a simple offset derived from controller.

      // Let's use a time based offset for smoother continuous appearance if we were updating state.
      // Since we are invalidating paint via the controller, we can use the controller value.
      // However, 0..1 loop causes a jump.
      // The controller is just a ticker here. We will assume the system is robust enough or
      // just render static particles for the sake of complexity.
      // Let's make them rise based on a calculated offset that wraps.

      double travelDistance = size.height + 100;
      double currentY =
          (particle.position.dy -
              (progress * travelDistance * particle.speed)) %
          travelDistance;
      if (currentY < -50) currentY += travelDistance;

      // Opacity fade in/out
      double opacity = 1.0;
      if (currentY > size.height - 100) {
        opacity = (size.height - currentY) / 100;
      } else if (currentY < 100) {
        opacity = currentY / 100;
      }
      opacity = opacity.clamp(0.0, 1.0);

      paint.color = particle.color.withValues(
        alpha: particle.color.a * opacity,
      );

      canvas.drawCircle(
        Offset(particle.position.dx, currentY),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
