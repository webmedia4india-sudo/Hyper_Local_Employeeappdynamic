import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'package:hyper_local_employee/Splash/employeeonbaordingscreenpage.dart';

class EmployeeSplashScreenPage extends StatefulWidget {
  const EmployeeSplashScreenPage({super.key});

  @override
  State<EmployeeSplashScreenPage> createState() => _EmployeeSplashScreenPageState();
}

class _EmployeeSplashScreenPageState extends State<EmployeeSplashScreenPage>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  // Pulse animation for the logo icon
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Ripple animation for expanding circles behind the logo
  late final AnimationController _rippleController;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (scale + fade)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // 2. Pulse animation for the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Ripple animation for expanding circles
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _entranceController.forward();

    // Navigate to Onboarding after splash
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeOnboardingScreenPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Stack for Ripple Rings + Pulsing Logo
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Expanding Ripple Rings
                                AnimatedBuilder(
                                  animation: _rippleController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      size: const Size(220, 220),
                                      painter: _RipplePainter(
                                        progress: _rippleController.value,
                                        color: AppColors.primaryLight.withOpacity(0.4),
                                      ),
                                    );
                                  },
                                ),

                                // Pulsing Logo Icon
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.background,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryLight.withOpacity(0.25),
                                          blurRadius: 30,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Icon(
                                      Icons.bolt_rounded, // Replace with logo asset if needed
                                      size: 65,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Logo Text
                          Text(
                            'Hyper Local',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 237, 240, 242),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom spacing (dotted line removed)
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: SizedBox(height: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Radar-style expanding ripple rings painter
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    const ringCount = 3;

    for (int i = 0; i < ringCount; i++) {
      // Calculate delayed phase for each ring to stagger them
      final phase = (progress + (i / ringCount)) % 1.0;
      final radius = 35 + (maxRadius - 35) * phase;
      final opacity = (1.0 - phase).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}