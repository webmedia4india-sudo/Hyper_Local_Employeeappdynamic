import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_local_employee/Splash/employeeloginpage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EmployeeOnboardingScreenPage extends StatefulWidget {
  /// Called when the user taps "Get Started" on the last page.
  final VoidCallback? onGetStarted;

  const EmployeeOnboardingScreenPage({super.key, this.onGetStarted});

  @override
  State<EmployeeOnboardingScreenPage> createState() => _EmployeeOnboardingScreenPageState();
}

class _EmployeeOnboardingScreenPageState extends State<EmployeeOnboardingScreenPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isPressed = false;
  bool get _isLastPage => _currentIndex == 1;

  @override
  void dispose() {
    _pageController.dispose();
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
              // Top Bar (Skip button removed)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: SizedBox(height: 24),
              ),

              // PageView Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    // First Screen: IT Job Openings
                    _OnboardingItem(
                      title: "Find IT Job Openings",
                      subtitle: "Discover local software developer, UI/UX designer, QA tester, and IT support positions matching your skillset.",
                      illustration: const _AnimatedITCodeIllustration(),
                      isActive: _currentIndex == 0,
                    ),
                    // Second Screen: IT Career Growth
                    _OnboardingItem(
                      title: "IT Career Growth",
                      subtitle: "Showcase your tech stack, track coding test scores, and accelerate your career in the IT industry.",
                      illustration: const _AnimatedITGrowthIllustration(),
                      isActive: _currentIndex == 1,
                    ),
                  ],
                ),
              ),

              // Bottom Section: Indicators & Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    // Page Indicator Dot
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.textHint,
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 8,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Action Button (Next / Get Started) with press animation
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isPressed = true),
                      onTapUp: (_) => setState(() => _isPressed = false),
                      onTapCancel: () => setState(() => _isPressed = false),
                      onTap: () {
                        if (_isLastPage) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmployeeLoginPage(),
                            ),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: AnimatedScale(
                        scale: _isPressed ? 0.96 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 58,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.buttonPrimary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(_isPressed ? 0.15 : 0.35),
                                blurRadius: _isPressed ? 6 : 14,
                                offset: Offset(0, _isPressed ? 2 : 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) => FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.2, 0),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                ),
                                child: Text(
                                  _isLastPage ? "Get Started" : "Next",
                                  key: ValueKey(_isLastPage),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.buttonText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.buttonText,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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

class _OnboardingItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget illustration;
  final bool isActive;

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.isActive,
  });

  @override
  State<_OnboardingItem> createState() => _OnboardingItemState();
}

class _OnboardingItemState extends State<_OnboardingItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _titleSlide;
  late final Animation<double> _subtitleSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    // Illustration pops in with a slight overshoot for a livelier feel
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Title & subtitle staggered in one after another
    _titleSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.isActive) {
      _animController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _OnboardingItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animController.forward(from: 0);
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration Container with pop-in scale
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 280, maxWidth: 320),
                          child: widget.illustration,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title (16) — staggered slide/fade in
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle (14) — staggered slightly after title
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _subtitleSlide.value),
                      child: Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// NEW ILLUSTRATION 1: Glassmorphic IT/Code Editor Terminal Mock
// -----------------------------------------------------------------------------
class _AnimatedITCodeIllustration extends StatefulWidget {
  const _AnimatedITCodeIllustration();

  @override
  State<_AnimatedITCodeIllustration> createState() =>
      _AnimatedITCodeIllustrationState();
}

class _AnimatedITCodeIllustrationState
    extends State<_AnimatedITCodeIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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

  Widget _buildCodeLine({required double width, required Color color}) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        final float1 = sin(val * 2 * pi) * 8;
        final float2 = cos(val * 2 * pi + 1.2) * 10;
        final float3 = sin(val * 2 * pi * 2) * 5;
        final tilt = sin(val * 2 * pi) * 0.03; // subtle 3D-ish tilt
        final glowPulse = 0.04 + (sin(val * 2 * pi) + 1) * 0.03; // pulsing bg glow

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background glowing light — now pulsing
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(glowPulse),
              ),
            ),

            // Central Glassmorphic Terminal/Code Window with float + tilt
            Transform.translate(
              offset: Offset(0, float3),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateZ(tilt),
                child: Container(
                  width: 160,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08 + (sin(val * 2 * pi) + 1) * 0.02),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mac-like title bar dots
                        Row(
                          children: [
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                            const SizedBox(width: 3),
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                            const SizedBox(width: 3),
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Code Mock lines — each line "typing" width pulses slightly
                        _buildCodeLine(width: 60 + sin(val * 2 * pi) * 4, color: Colors.blue.shade300),
                        const SizedBox(height: 6),
                        _buildCodeLine(width: 100 + cos(val * 2 * pi) * 4, color: Colors.purple.shade300),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _buildCodeLine(width: 80 + sin(val * 2 * pi + 1) * 4, color: Colors.green.shade300),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _buildCodeLine(width: 50, color: Colors.amber.shade400),
                        ),
                        const SizedBox(height: 6),
                        _buildCodeLine(width: 40 + cos(val * 2 * pi + 1) * 4, color: Colors.blue.shade300),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating Card 1 (Top Left): "React Developer"
            Positioned(
              left: 0,
              top: 20,
              child: Transform.translate(
                offset: Offset(0, float1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.code_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "React Developer",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Card 2 (Bottom Right): "98% Match"
            Positioned(
              right: 0,
              bottom: 20,
              child: Transform.translate(
                offset: Offset(0, float2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Job Match",
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "98% Match",
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating 3D Code Tag Symbol (Top Right) — now with pulsing glow ring
            Positioned(
              right: 15,
              top: 15,
              child: Transform.translate(
                offset: Offset(0, -float1),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coral,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withOpacity(0.25 + (sin(val * 2 * pi) + 1) * 0.1),
                        blurRadius: 6 + (sin(val * 2 * pi) + 1) * 3,
                        spreadRadius: 1 + (sin(val * 2 * pi) + 1) * 0.5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.terminal_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// NEW ILLUSTRATION 2: IT Career Growth / Tech Stack Development
// -----------------------------------------------------------------------------
class _AnimatedITGrowthIllustration extends StatefulWidget {
  const _AnimatedITGrowthIllustration();

  @override
  State<_AnimatedITGrowthIllustration> createState() =>
      _AnimatedITGrowthIllustrationState();
}

class _AnimatedITGrowthIllustrationState
    extends State<_AnimatedITGrowthIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        final float1 = sin(val * 2 * pi + 2) * 8;
        final float2 = cos(val * 2 * pi + 3) * 10;
        final float3 = sin(val * 2 * pi) * 5;
        final glowPulse = 0.04 + (cos(val * 2 * pi) + 1) * 0.03;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background glow — pulsing
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(glowPulse),
              ),
            ),

            // Glassmorphic Central Stats Card
            Transform.translate(
              offset: Offset(0, float3),
              child: Container(
                width: 170,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08 + (cos(val * 2 * pi) + 1) * 0.02),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomPaint(
                    painter: _GrowthChartPainter(progress: val),
                  ),
                ),
              ),
            ),

            // Floating Pill 1 (Top Right): "Flutter Dev"
            Positioned(
              right: 0,
              top: 15,
              child: Transform.translate(
                offset: Offset(0, float1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "Flutter Dev",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Pill 2 (Bottom Left): "Score 98%"
            Positioned(
              left: 0,
              bottom: 15,
              child: Transform.translate(
                offset: Offset(0, float2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "Score 98%",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Tech Badge (Top Left) — continuous 3D spin, unchanged trigger
            Positioned(
              left: 15,
              top: 15,
              child: Transform.translate(
                offset: Offset(0, -float1),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(val * 2 * pi),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.coral, AppColors.primary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coral.withOpacity(0.3 + (sin(val * 2 * pi) + 1) * 0.1),
                          blurRadius: 6 + (sin(val * 2 * pi) + 1) * 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "IT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class _GrowthChartPainter extends CustomPainter {
  final double progress;

  _GrowthChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Line chart path calculations
    final path = Path();
    final fillPath = Path();

    final startX = 15.0;
    final endX = size.width - 15;
    final widthRange = endX - startX;
    final baseY = size.height - 20;

    final points = <Offset>[];
    for (int i = 0; i <= 10; i++) {
      final pct = i / 10.0;
      final x = startX + widthRange * pct;
      final y = baseY - 20 - sin((pct * 2 * pi) - (progress * 2 * pi)) * 15;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, baseY);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    fillPath.lineTo(points.last.dx, baseY);
    fillPath.close();

    // Translucent gradient fill
    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withOpacity(0.2),
        AppColors.primary.withOpacity(0.0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paintLine);

    // Draw growth bars at the bottom — animated pulsing height
    final barPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final barW = (size.width - 40) / 7;
    for (int i = 0; i < 7; i++) {
      final h = 15 + sin(progress * 2 * pi + i) * 6 + 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(20 + i * (barW + 2), baseY - h, barW, h),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}