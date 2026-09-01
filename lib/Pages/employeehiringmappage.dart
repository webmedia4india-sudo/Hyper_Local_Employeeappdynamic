import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart'; // update to your actual AppColors import path

class EmployeeHiringMapPage extends StatefulWidget {
  const EmployeeHiringMapPage({super.key});

  @override
  State<EmployeeHiringMapPage> createState() => _EmployeeHiringMapPageState();
}

class _EmployeeHiringMapPageState extends State<EmployeeHiringMapPage>
    with TickerProviderStateMixin {
  String _selectedCity = "Mumbai, Maharashtra";
  String _selectedRadius = "10 KM";

  final List<String> _cities = const [
    "Mumbai, Maharashtra",
    "Pune, Maharashtra",
    "Nagpur, Maharashtra",
    "Delhi, NCR",
  ];

  final List<String> _radii = const ["5 KM", "10 KM", "15 KM", "25 KM"];

  // Heat blobs positioned as fractions of the map area (dx, dy in 0..1), with intensity 0..1
  final List<_HeatSpot> _heatSpots = const [
    _HeatSpot(dx: 0.42, dy: 0.32, intensity: 1.0, radius: 70),
    _HeatSpot(dx: 0.62, dy: 0.40, intensity: 0.85, radius: 55),
    _HeatSpot(dx: 0.40, dy: 0.60, intensity: 0.75, radius: 60),
  ];

  // Small location pin markers scattered on the map, like the reference image
  final List<Offset> _pins = const [
    Offset(0.12, 0.20),
    Offset(0.85, 0.18),
    Offset(0.08, 0.55),
    Offset(0.90, 0.62),
    Offset(0.18, 0.85),
  ];

  // ── Animation controllers ──
  late final AnimationController _pulseController; // continuous heat-spot pulse
  late final AnimationController _introController; // one-shot entrance (map fade, pins drop, legend fade)

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Hiring Heatmap",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── City selector (fades + slides down in) ──
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _introController,
              curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
                CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                        items: _cities
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCity = val);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Map with animated heatmap ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Base "map" background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FakeMapPainter(),
                        ),
                      ),

                      // Heatmap blobs — continuously pulsing
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _HeatmapPainter(
                                    spots: _heatSpots,
                                    size: Size(constraints.maxWidth, constraints.maxHeight),
                                    pulse: _pulseController.value,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Location pins — staggered drop-in with bounce
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: List.generate(_pins.length, (i) {
                              final p = _pins[i];
                              // stagger each pin's animation window across the intro timeline
                              final start = 0.35 + (i * 0.08);
                              final end = (start + 0.35).clamp(0.0, 1.0);
                              final curved = CurvedAnimation(
                                parent: _introController,
                                curve: Interval(start.clamp(0.0, 1.0), end, curve: Curves.easeOutBack),
                              );

                              return Positioned(
                                left: p.dx * constraints.maxWidth - 12,
                                top: p.dy * constraints.maxHeight - 24,
                                child: AnimatedBuilder(
                                  animation: curved,
                                  builder: (context, child) {
                                    final t = curved.value.clamp(0.0, 1.0);
                                    return Opacity(
                                      opacity: t,
                                      child: Transform.translate(
                                        offset: Offset(0, -16 * (1 - curved.value)),
                                        child: Transform.scale(
                                          scale: curved.value,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppColors.mapPinBlue,
                                    size: 24,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      // Radius selector (top-right)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRadius,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _radii
                                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedRadius = val);
                              },
                            ),
                          ),
                        ),
                      ),

                      // Zoom controls (bottom-right)
                      Positioned(
                        right: 12,
                        bottom: 90,
                        child: Column(
                          children: [
                            _AnimatedMapButton(icon: Icons.add, onTap: () {}),
                            const SizedBox(height: 8),
                            _AnimatedMapButton(icon: Icons.remove, onTap: () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Legend (fades + slides up in, last) ──
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _introController,
              curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withOpacity(0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _legendItem("High", AppColors.error),
                      _legendItem("Medium", AppColors.warning),
                      _legendItem("Low", const Color(0xFFFFD54F)),
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

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Zoom control button with a subtle tap-scale animation.
class _AnimatedMapButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AnimatedMapButton({required this.icon, required this.onTap});

  @override
  State<_AnimatedMapButton> createState() => _AnimatedMapButtonState();
}

class _AnimatedMapButtonState extends State<_AnimatedMapButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _HeatSpot {
  final double dx; // 0..1 fraction of width
  final double dy; // 0..1 fraction of height
  final double intensity; // 0..1
  final double radius; // px

  const _HeatSpot({
    required this.dx,
    required this.dy,
    required this.intensity,
    required this.radius,
  });
}

class _HeatmapPainter extends CustomPainter {
  final List<_HeatSpot> spots;
  final Size size;
  final double pulse; // 0..1, drives the breathing animation

  _HeatmapPainter({required this.spots, required this.size, required this.pulse});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // pulse oscillates 0..1 (reverse: true), map it to a gentle scale + opacity breathing range
    final scaleFactor = 1.0 + (pulse * 0.12); // 1.0 -> 1.12
    final opacityFactor = 0.85 + (pulse * 0.15); // 0.85 -> 1.0

    for (final spot in spots) {
      final center = Offset(spot.dx * canvasSize.width, spot.dy * canvasSize.height);
      final animatedRadius = spot.radius * scaleFactor;

      final gradient = RadialGradient(
        colors: [
          Colors.red.withOpacity(0.55 * spot.intensity * opacityFactor),
          Colors.orange.withOpacity(0.45 * spot.intensity * opacityFactor),
          Colors.yellow.withOpacity(0.25 * spot.intensity * opacityFactor),
          Colors.yellow.withOpacity(0.0),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      );

      final rect = Rect.fromCircle(center: center, radius: animatedRadius);
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = BlendMode.multiply;

      canvas.drawCircle(center, animatedRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) => oldDelegate.pulse != pulse;
}

/// Lightweight stand-in for a real map background (roads / blocks / green
/// patches) so the page doesn't require a Maps SDK / API key to render.
/// Swap this widget for a real GoogleMap/Mapbox widget when ready.
class _FakeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // base land color
    final landPaint = Paint()..color = const Color(0xFFF2EFE9);
    canvas.drawRect(Offset.zero & size, landPaint);

    // water patch (bottom-right, like a coastline)
    final waterPaint = Paint()..color = const Color(0xFFCFE3F0);
    final waterPath = Path()
      ..moveTo(size.width * 0.7, size.height)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // green patches (parks)
    final greenPaint = Paint()..color = const Color(0xFFDCEBD8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.62, size.width * 0.24, size.height * 0.18),
        const Radius.circular(10),
      ),
      greenPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.08, size.width * 0.2, size.height * 0.14),
        const Radius.circular(10),
      ),
      greenPaint,
    );

    // roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    for (double y = size.height * 0.15; y < size.height; y += size.height * 0.18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - size.height * 0.05), roadPaint);
    }
    for (double x = size.width * 0.15; x < size.width; x += size.width * 0.22) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.width * 0.05, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FakeMapPainter oldDelegate) => false;
}