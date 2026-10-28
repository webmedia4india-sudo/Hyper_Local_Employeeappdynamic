import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/models/job_post_model.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/services/user_session.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeHiringDashboardPage extends StatefulWidget {
  const EmployeeHiringDashboardPage({super.key});

  @override
  State<EmployeeHiringDashboardPage> createState() => _EmployeeHiringDashboardPageState();
}

class _EmployeeHiringDashboardPageState extends State<EmployeeHiringDashboardPage> {
  String _selectedRange = "This Month";
  final List<String> _ranges = const ["This Week", "This Month", "This Year"];

  bool _isLoading = false;
  int _totalViews = 0;
  int _applicationsCount = 0;
  int _interviewsCount = 0;
  int _hiredCount = 0;

  // Applications trend data (x label, y value)
  List<_TrendPoint> _trend = const [];

  // Top performing jobs
  List<_JobItem> _topJobs = const [];

  // Raw fetched data for the logged-in employer
  List<Map<String, dynamic>> _rawApplications = [];
  List<Map<String, dynamic>> _rawInvitations = [];
  List<JobPostModel> _rawJobs = [];

  @override
  void initState() {
    super.initState();
    if (UserSession.currentEmployee == null) {
      UserSession.init().then((_) {
        if (mounted) {
          _loadDashboardData();
        }
      });
    } else {
      _loadDashboardData();
    }
    UserSession.userNotifier.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  @override
  void dispose() {
    UserSession.userNotifier.removeListener(_onSessionChanged);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        token = UserSession.token;
      }

      int? employerId = prefs.getInt('employer_id');
      if (employerId == null) {
        final raw = prefs.get('employer_id');
        if (raw != null) employerId = int.tryParse(raw.toString());
      }
      employerId ??= prefs.getInt('employee_id');
      if (employerId == null) {
        final raw = prefs.get('employee_id');
        if (raw != null) employerId = int.tryParse(raw.toString());
      }
      if (employerId == null && UserSession.currentEmployee != null) {
        employerId = UserSession.currentEmployee!.id;
      }
      employerId ??= await UserSession.getEmployerId();

      List<JobPostModel> jobs = [];
      List<Map<String, dynamic>> applications = [];
      List<Map<String, dynamic>> invitations = [];

      await Future.wait([
        // 1. Fetch employer's jobs
        () async {
          try {
            if (token != null && token.isNotEmpty) {
              jobs = await ApiService.fetchMyJobPosts(token);
            }
          } catch (e) {
            debugPrint('[HiringDashboard] Error fetching jobs: $e');
          }
        }(),

        // 2. Fetch employer's applications
        () async {
          try {
            if (employerId != null && employerId > 0) {
              applications = await ApiService.getEmployerApplications(employerId);
            }
          } catch (e) {
            debugPrint('[HiringDashboard] Error fetching applications: $e');
          }
        }(),

        // 3. Fetch employer's interview invitations
        () async {
          try {
            if (employerId != null && employerId > 0) {
              invitations = await ApiService.getEmployerInvitations(employerId);
            }
          } catch (e) {
            debugPrint('[HiringDashboard] Error fetching invitations: $e');
          }
        }(),
      ]);

      if (mounted) {
        _rawJobs = jobs;
        _rawApplications = applications;
        _rawInvitations = invitations;
        _applyFilter();
      }
    } catch (e) {
      debugPrint('[HiringDashboard] Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (_selectedRange) {
      case "This Week":
        // Monday of current week 00:00:00 to Sunday 23:59:59.999
        final monday = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(monday.year, monday.month, monday.day);
        final sunday = now.add(Duration(days: 7 - now.weekday));
        end = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
        break;
      case "This Year":
        // Jan 1 to Dec 31
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;
      case "This Month":
      default:
        // 1st of month to last millisecond of month
        start = DateTime(now.year, now.month, 1);
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        end = nextMonth.subtract(const Duration(milliseconds: 1));
        break;
    }

    // Filter applications within selected date range
    final filteredApps = _rawApplications.where((app) {
      final dt = _parseDate(app['applied_at'] ?? app['created_at']);
      if (dt == null) return false;
      return !dt.isBefore(start) && !dt.isAfter(end);
    }).toList();

    // Filter interviews within selected date range
    final filteredInvs = _rawInvitations.where((inv) {
      final dt = _parseDate(inv['interview_date'] ?? inv['sent_at'] ?? inv['created_at']);
      if (dt == null) return false;
      return !dt.isBefore(start) && !dt.isAfter(end);
    }).toList();

    // Summary counts
    final appCount = filteredApps.length;
    final intCount = filteredInvs.length;

    // Hired: applications in period with status 'hired', 'selected', or 'offer_accepted'
    final hiredCount = filteredApps.where((app) {
      final status = (app['application_status'] ?? '').toString().toLowerCase().trim();
      return status == 'hired' || status == 'selected' || status == 'offer_accepted';
    }).length;

    // Total Views: Not tracked by database/backend -> 0 dynamically without fabricating
    const viewsCount = 0;

    // Trend points grouped by date
    final trendPoints = _buildTrendPoints(filteredApps, start, end, now);

    // Top performing jobs
    final topJobs = _buildTopJobs(filteredApps);

    setState(() {
      _totalViews = viewsCount;
      _applicationsCount = appCount;
      _interviewsCount = intCount;
      _hiredCount = hiredCount;
      _trend = trendPoints;
      _topJobs = topJobs;
    });
  }

  List<_TrendPoint> _buildTrendPoints(
    List<Map<String, dynamic>> apps,
    DateTime start,
    DateTime end,
    DateTime now,
  ) {
    final points = <_TrendPoint>[];

    if (_selectedRange == "This Week") {
      // 7 days: Monday to Sunday
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      for (int i = 0; i < 7; i++) {
        final d = monday.add(Duration(days: i));
        final dayStart = DateTime(d.year, d.month, d.day);
        final dayEnd = DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
        final count = apps.where((a) {
          final dt = _parseDate(a['applied_at'] ?? a['created_at']);
          return dt != null && !dt.isBefore(dayStart) && !dt.isAfter(dayEnd);
        }).length;
        points.add(_TrendPoint(dayLabels[i], count.toDouble()));
      }
    } else if (_selectedRange == "This Year") {
      // 6 bi-monthly intervals: Jan-Feb, Mar-Apr, May-Jun, Jul-Aug, Sep-Oct, Nov-Dec
      final monthLabels = ["Feb", "Apr", "Jun", "Aug", "Oct", "Dec"];
      for (int i = 0; i < 6; i++) {
        final startMonth = i * 2 + 1;
        final endMonth = i * 2 + 2;
        final intervalStart = DateTime(now.year, startMonth, 1);
        final nextM = DateTime(now.year, endMonth + 1, 1);
        final intervalEnd = nextM.subtract(const Duration(milliseconds: 1));
        final count = apps.where((a) {
          final dt = _parseDate(a['applied_at'] ?? a['created_at']);
          return dt != null && !dt.isBefore(intervalStart) && !dt.isAfter(intervalEnd);
        }).length;
        points.add(_TrendPoint(monthLabels[i], count.toDouble()));
      }
    } else {
      // "This Month": 5 checkpoints across the month matching the original mockup UI ("01 May", "08 May", "15 May", "23 May", "29 May")
      final monthStr = _monthShort(now.month);
      final lastDay = DateTime(now.year, now.month + 1, 0).day;

      final intervals = [
        [1, 7, "01 $monthStr"],
        [8, 14, "08 $monthStr"],
        [15, 21, "15 $monthStr"],
        [22, 28, "22 $monthStr"],
        [29, lastDay, "${lastDay.toString().padLeft(2, '0')} $monthStr"],
      ];

      for (final interval in intervals) {
        final d1 = interval[0] as int;
        final d2 = interval[1] as int;
        final label = interval[2] as String;
        final intervalStart = DateTime(now.year, now.month, d1);
        final intervalEnd = DateTime(now.year, now.month, d2, 23, 59, 59, 999);

        final count = apps.where((a) {
          final dt = _parseDate(a['applied_at'] ?? a['created_at']);
          return dt != null && !dt.isBefore(intervalStart) && !dt.isAfter(intervalEnd);
        }).length;

        points.add(_TrendPoint(label, count.toDouble()));
      }
    }

    return points;
  }

  List<_JobItem> _buildTopJobs(List<Map<String, dynamic>> periodApps) {
    final Map<int, int> appCountByJobId = {};
    final Map<int, String> jobTitleById = {};

    // Populate from employer's jobs list
    for (final j in _rawJobs) {
      if (j.id != null) {
        jobTitleById[j.id!] = (j.jobTitle != null && j.jobTitle!.trim().isNotEmpty)
            ? j.jobTitle!.trim()
            : "Job #${j.id}";
        appCountByJobId[j.id!] = 0;
      }
    }

    // Count applications in the selected period (or from all employer applications if period is empty)
    final appsToCount = periodApps.isNotEmpty ? periodApps : _rawApplications;

    for (final a in appsToCount) {
      final rawId = a['job_post_id'] ?? a['job_id'];
      final jobId = int.tryParse(rawId?.toString() ?? '');
      if (jobId != null) {
        appCountByJobId[jobId] = (appCountByJobId[jobId] ?? 0) + 1;
        if (!jobTitleById.containsKey(jobId)) {
          final title = (a['job_title'] ?? 'Job #$jobId').toString().trim();
          if (title.isNotEmpty) {
            jobTitleById[jobId] = title;
          }
        }
      }
    }

    final list = <_JobItem>[];
    appCountByJobId.forEach((jobId, count) {
      list.add(_JobItem(
        title: jobTitleById[jobId] ?? "Job #$jobId",
        applications: count,
      ));
    });

    // Sort descending by applications count
    list.sort((a, b) => b.applications.compareTo(a.applications));

    // Limit to top 5 jobs for clean display
    return list.take(5).toList();
  }

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString())?.toLocal();
  }

  static String _monthShort(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    if (m >= 1 && m <= 12) return months[m - 1];
    return "";
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final str = number.toString();
      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    }
    return number.toString();
  }

  String _formatHired(int number) {
    if (number < 10) {
      return number.toString().padLeft(2, '0');
    }
    return _formatNumber(number);
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
                  color: Colors.white.withValues(alpha: 0.18),
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
                      if (val != null) {
                        setState(() => _selectedRange = val);
                        _applyFilter();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stat cards grid ──
              Row(
                children: [
                  Expanded(child: _buildStatCard("Total Views", _formatNumber(_totalViews))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Applications", _formatNumber(_applicationsCount))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Interviews", _formatNumber(_interviewsCount))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Hired", _formatHired(_hiredCount))),
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
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllJobsPage()),
                      );
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
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                ),
                child: _topJobs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Center(
                          child: Text(
                            _isLoading ? "Loading jobs..." : "No job postings found",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : Column(
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
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

    // Dynamically calculate maxY and yTicks based on actual data
    final double maxVal = points.isEmpty
        ? 0.0
        : points.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    double maxY;
    List<double> yTicks;

    if (maxVal <= 0) {
      maxY = 5;
      yTicks = [0, 2, 4];
    } else if (maxVal <= 4) {
      maxY = 5;
      yTicks = [0, 2, 4];
    } else if (maxVal <= 10) {
      maxY = 10;
      yTicks = [0, 5, 10];
    } else if (maxVal <= 25) {
      maxY = 25;
      yTicks = [0, 10, 20];
    } else if (maxVal <= 50) {
      maxY = 50;
      yTicks = [0, 25, 50];
    } else if (maxVal <= 100) {
      maxY = 100;
      yTicks = [0, 50, 100];
    } else {
      maxY = ((maxVal * 1.25) / 10).ceil() * 10.0;
      final step = (maxY / 3).roundToDouble();
      yTicks = [0, step, step * 2];
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;

    final labelStyle = const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10);

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
      final clampedVal = points[i].value.clamp(0.0, maxY);
      final y = topPadding + chartHeight - (clampedVal / maxY) * chartHeight;
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
        colors: [lineColor.withValues(alpha: 0.18), lineColor.withValues(alpha: 0.0)],
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