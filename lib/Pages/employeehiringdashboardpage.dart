import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart'; // update to your actual AppColors import path

class EmployeeHiringDashboardPage extends StatefulWidget {
  const EmployeeHiringDashboardPage({super.key});

  @override
  State<EmployeeHiringDashboardPage> createState() => _EmployeeHiringDashboardPageState();
}

class _EmployeeHiringDashboardPageState extends State<EmployeeHiringDashboardPage> {
  String _selectedRange = "This Month";
  final List<String> _ranges = const ["This Week", "This Month", "This Year"];

  // ── Applications trend data (x label, y value) ──
  final List<_TrendPoint> _trend = const [
    _TrendPoint("01 May", 42),
    _TrendPoint("08 May", 68),
    _TrendPoint("15 May", 105),
    _TrendPoint("23 May", 78),
    _TrendPoint("29 May", 120),
  ];

  final List<_JobItem> _topJobs = const [
    _JobItem(title: "Sales Executive", applications: 88),
    _JobItem(title: "Field Technician", applications: 34),
    _JobItem(title: "Customer Support", applications: 21),
  ];

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
          "Hiring Dashboard",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRange,
                    dropdownColor: AppColors.primaryDark,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.buttonText, size: 18),
                    style: const TextStyle(
                      color: AppColors.buttonText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _ranges
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRange = val);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stat cards grid ──
            Row(
              children: [
                Expanded(child: _buildStatCard("Total Views", "4,582")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Applications", "156")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard("Interviews", "28")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Hired", "08")),
              ],
            ),

            const SizedBox(height: 26),

            // ── Applications Trend ──
            Text(
              "Applications Trend",
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
              ),
              child: SizedBox(
                height: 180,
                child: CustomPaint(
                  painter: _TrendChartPainter(points: _trend, lineColor: AppColors.primary),
                  child: Container(),
                ),
              ),
            ),

            const SizedBox(height: 26),

            // ── Top Performing Jobs ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Top Performing Jobs",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: navigate to full jobs list
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
              ),
              child: Column(
                children: List.generate(_topJobs.length, (index) {
                  final job = _topJobs[index];
                  final isLast = index == _topJobs.length - 1;
                  final accent = AppColors.accents[index % AppColors.accents.length];
                  final accentSoft = AppColors.accentsSoft[index % AppColors.accentsSoft.length];

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(bottom: BorderSide(color: AppColors.divider)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accentSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.badge_outlined, color: accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            job.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          "${job.applications} Applications",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPoint {
  final String label;
  final double value;
  const _TrendPoint(this.label, this.value);
}

class _JobItem {
  final String title;
  final int applications;
  const _JobItem({required this.title, required this.applications});
}

class _TrendChartPainter extends CustomPainter {
  final List<_TrendPoint> points;
  final Color lineColor;

  _TrendChartPainter({required this.points, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 30;
    const double bottomPadding = 22;
    const double topPadding = 6;

    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    const double maxY = 150;
    const List<double> yTicks = [0, 50, 100];

    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(color: const Color(0xFF9CA3AF), fontSize: 10);

    // ── horizontal grid lines + y labels ──
    for (final tick in yTicks) {
      final y = topPadding + chartHeight - (tick / maxY) * chartHeight;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width, y),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(text: tick.toInt().toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    if (points.isEmpty) return;

    // ── compute point offsets ──
    final dx = points.length > 1 ? chartWidth / (points.length - 1) : 0.0;
    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = leftPadding + dx * i;
      final y = topPadding + chartHeight - (points[i].value / maxY) * chartHeight;
      offsets.add(Offset(x, y));
    }

    // ── filled area under line ──
    final fillPath = Path()..moveTo(offsets.first.dx, topPadding + chartHeight);
    for (final o in offsets) {
      fillPath.lineTo(o.dx, o.dy);
    }
    fillPath.lineTo(offsets.last.dx, topPadding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.18), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));
    canvas.drawPath(fillPath, fillPaint);

    // ── smooth-ish line through points ──
    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // ── dots on each point ──
    final dotPaint = Paint()..color = lineColor;
    final dotBorderPaint = Paint()..color = Colors.white;
    for (final o in offsets) {
      canvas.drawCircle(o, 5, dotBorderPaint);
      canvas.drawCircle(o, 3.5, dotPaint);
    }

    // ── x-axis labels ──
    for (int i = 0; i < points.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: points[i].label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = offsets[i].dx - tp.width / 2;
      tp.paint(canvas, Offset(x, size.height - bottomPadding + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}