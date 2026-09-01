import 'package:flutter/material.dart';
import 'package:hyper_local_employee/Pages/employeeinterviewschedulepage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeApplicationDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? application;

  const EmployeeApplicationDetailsPage({super.key, this.application});

  @override
  State<EmployeeApplicationDetailsPage> createState() =>
      _EmployeeApplicationDetailsPageState();
}

class _EmployeeApplicationDetailsPageState
    extends State<EmployeeApplicationDetailsPage>
    with TickerProviderStateMixin {
  // ── Timeline steps — mark completed/current/pending as needed ──
  final List<Map<String, dynamic>> _timeline = const [
    {
      'title': 'Application Submitted',
      'time': '12 May, 10:30 AM',
      'state': 'done',
    },
    {'title': 'Reviewed by you', 'time': '12 May, 11:15 AM', 'state': 'done'},
    {'title': 'Shortlisted', 'time': '12 May, 11:20 AM', 'state': 'done'},
    {
      'title': 'Interview Scheduled',
      'time': '13 May, 03:00 PM',
      'state': 'done',
    },
    {'title': 'Offer Pending', 'time': '', 'state': 'pending'},
  ];

  // ── Staggered entrance animation for timeline tiles ──
  late final AnimationController _staggerController;

  // ── Pulse animation for the current/next step dot ──
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // ── Fade + slide animation for the profile card ──
  late final AnimationController _cardController;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  int get _currentStepIndex {
    final idx = _timeline.indexWhere((s) => s['state'] != 'done');
    return idx == -1 ? _timeline.length - 1 : idx;
  }

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + _timeline.length * 220),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Kick things off: card first, then the timeline staggers in.
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _staggerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.application?['name'] as String? ?? 'Rahul Verma';
    final String role =
        widget.application?['role'] as String? ?? 'Flutter Developer';
    final String appliedOn =
        widget.application?['appliedOn'] as String? ??
        'Applied on 12 May, 10:30 AM';

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
          "Application Details",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: _buildProfileCard(name, role, appliedOn),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    "Timeline",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildTimeline(_timeline),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  // ── PROFILE HEADER CARD ──
  Widget _buildProfileCard(String name, String role, String appliedOn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Applied for $role",
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  appliedOn,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "2.1 km away",
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TIMELINE (animated vertical stepper) ──
  Widget _buildTimeline(List<Map<String, dynamic>> steps) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final bool isLast = index == steps.length - 1;
          final bool isDone = step['state'] == 'done';
          final bool isCurrent = index == _currentStepIndex && !isDone;

          return _buildTimelineTile(
            index: index,
            total: steps.length,
            title: step['title'] as String,
            time: step['time'] as String,
            isDone: isDone,
            isCurrent: isCurrent,
            isLast: isLast,
          );
        }),
      ),
    );
  }

  Widget _buildTimelineTile({
    required int index,
    required int total,
    required String title,
    required String time,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    // Each tile gets its own slice of the overall stagger timeline.
    final double start = (index / total) * 0.7;
    final double end = (start + 0.4).clamp(0.0, 1.0);
    final Interval tileInterval = Interval(
      start,
      end,
      curve: Curves.easeOutCubic,
    );

    final Animation<double> fade = CurvedAnimation(
      parent: _staggerController,
      curve: tileInterval,
    );
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(-0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _staggerController, curve: tileInterval));

    // The connecting line "draws" itself in shortly after the dot appears.
    final Interval lineInterval = Interval(
      (start + 0.15).clamp(0.0, 1.0),
      (end + 0.25).clamp(0.0, 1.0),
      curve: Curves.easeInOut,
    );
    final Animation<double> lineGrow = CurvedAnimation(
      parent: _staggerController,
      curve: lineInterval,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_staggerController, _pulseController]),
      builder: (context, child) {
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(
            offset: Offset(slide.value.dx * 40, 0),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dot + connecting line ──
            Column(
              children: [
                _buildDot(isDone: isDone, isCurrent: isCurrent),
                if (!isLast)
                  Expanded(
                    child: AnimatedBuilder(
                      animation: lineGrow,
                      builder: (context, _) {
                        return Align(
                          alignment: Alignment.topCenter,
                          heightFactor: lineGrow.value.clamp(0.0, 1.0),
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: isDone
                                ? AppColors.primary.withOpacity(0.4)
                                : AppColors.border,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // ── Text content ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDone
                            ? AppColors.textPrimary
                            : (isCurrent
                                  ? AppColors.primary
                                  : AppColors.textHint),
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DOT with checkmark (done) or pulsing ring (current/next step) ──
  Widget _buildDot({required bool isDone, required bool isCurrent}) {
    if (isCurrent) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final double pulse = _pulseAnimation.value;
          return SizedBox(
            width: 30,
            height: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // outer pulsing ring
                Opacity(
                  opacity: (1 - pulse) * 0.5,
                  child: Container(
                    width: 18 + (pulse * 14),
                    height: 18 + (pulse * 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                ),
                // static inner dot
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary, width: 1.8),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppColors.primary : Colors.white,
        border: Border.all(
          color: isDone ? AppColors.primary : AppColors.border,
          width: 1.6,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }

  // ── BOTTOM ACTION BUTTONS ──
  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // hook up message action here
                },
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                label: const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const EmployeeInterviewSchedulePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'View Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}