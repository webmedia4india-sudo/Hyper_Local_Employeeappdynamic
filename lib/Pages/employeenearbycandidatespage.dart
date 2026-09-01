import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeNearbyCandidatesPage extends StatefulWidget {
  const EmployeeNearbyCandidatesPage({super.key});

  @override
  State<EmployeeNearbyCandidatesPage> createState() =>
      _EmployeeNearbyCandidatesPageState();
}

class _EmployeeNearbyCandidatesPageState
    extends State<EmployeeNearbyCandidatesPage>
    with TickerProviderStateMixin {
  // ── RADAR PULSE ANIMATION ──
  late final AnimationController _radarController;

  // ── CANDIDATE LIST ENTRANCE ANIMATION ──
  late final AnimationController _listController;

  final List<Map<String, dynamic>> _candidates = const [
    {
      'name': 'Rahul Verma',
      'role': 'Delivery Partner',
      'distance': '2.1 km away',
      'rating': '4.6',
      'color': AppColors.primary,
    },
    {
      'name': 'Sunil Yadav',
      'role': 'Delivery Partner',
      'distance': '2.9 km away',
      'rating': '4.8',
      'color': AppColors.coral,
    },
    {
      'name': 'Amit Singh',
      'role': 'Delivery Partner',
      'distance': '3.2 km away',
      'rating': '4.5',
      'color': AppColors.mint,
    },
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _listController.dispose();
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
          "Nearby Candidates",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // hook up filter/tune sheet here
            },
            icon: const Icon(Icons.tune_rounded, color: AppColors.buttonText),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMapSection(),
          Expanded(child: _buildCandidatesSheet()),
        ],
      ),
    );
  }

  // ── MAP MOCKUP WITH ANIMATED RADAR + PINS ──
  Widget _buildMapSection() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Base "map" background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEDEAF7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: CustomPaint(
                size: Size.infinite,
                painter: _MapGridPainter(),
              ),
            ),
          ),

          // Location pins scattered around
          const Positioned(top: 40, left: 40, child: _MapPin(color: AppColors.primary)),
          const Positioned(top: 90, right: 55, child: _MapPin(color: AppColors.primary)),
          const Positioned(bottom: 60, left: 70, child: _MapPin(color: AppColors.primary)),
          const Positioned(bottom: 40, right: 30, child: _MapPin(color: AppColors.coral, size: 30)),
          const Positioned(top: 30, right: 100, child: _MapPin(color: AppColors.primary, size: 18)),

          // Radar pulse rings + center radius badge
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _radarRing(0.0),
                      _radarRing(0.33),
                      _radarRing(0.66),
                      child!,
                    ],
                  );
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '10 KM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Radius range pill (top-left)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '50-500 m',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

          // Locate-me button (top-right)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.my_location_rounded,
                  color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radarRing(double phaseOffset) {
    // value cycles 0 -> 1 continuously; each ring is offset in phase
    // so three rings expand and fade out one after another.
    final double t = (_radarController.value + phaseOffset) % 1.0;
    final double scale = 0.3 + t * 1.6;
    final double opacity = (1 - t).clamp(0.0, 1.0) * 0.5;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── CANDIDATES BOTTOM SHEET ──
  Widget _buildCandidatesSheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_candidates.length * 83} Candidates Found',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // collapse / dismiss action can go here
                  },
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              itemCount: _candidates.length,
              itemBuilder: (context, index) {
                final candidate = _candidates[index];

                // Staggered fade + slide-in for each card
                final start = (index * 0.15).clamp(0.0, 1.0);
                final end = (start + 0.5).clamp(0.0, 1.0);
                final animation = CurvedAnimation(
                  parent: _listController,
                  curve: Interval(start, end, curve: Curves.easeOut),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: _buildCandidateCard(candidate),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final Color accent = candidate['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: accent, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  candidate['role'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      candidate['distance'] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
              const SizedBox(width: 3),
              Text(
                candidate['rating'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── SMALL LOCATION PIN MARKER ──
class _MapPin extends StatelessWidget {
  final Color color;
  final double size;
  const _MapPin({required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.location_on, color: color, size: size);
  }
}

// ── DECORATIVE MAP GRID/ROAD BACKGROUND ──
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final Paint faintPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.35, size.height),
      faintPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.6, size.height),
      faintPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.75),
      faintPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}