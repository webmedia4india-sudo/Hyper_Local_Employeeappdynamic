// C:\flutter-projects\hyper_local_employee\lib\employeehomepage.dart

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationpage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/Pages/employeeviewresumepage.dart';
import 'package:hyper_local_employee/Pages/employeecomapanyprofilepage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class CandidateProfile {
  final String initials;
  final String name;
  final String location;
  final String experience;
  final String noticePeriod;
  final String jobType;
  final String education;
  final String address;
  final String expectedCtc;
  final List<String> skills;
  final double matchPercent;
  final bool resumeAttached;
  final String imageUrl;

  CandidateProfile({
    required this.initials,
    required this.name,
    required this.location,
    required this.experience,
    required this.noticePeriod,
    required this.jobType,
    required this.education,
    required this.address,
    required this.expectedCtc,
    required this.skills,
    required this.matchPercent,
    required this.imageUrl,
    this.resumeAttached = true,
  });
}

class _EmployeeHomePageState extends State<EmployeeHomePage>
    with SingleTickerProviderStateMixin {
  final List<CandidateProfile> _candidates = [
    CandidateProfile(
      initials: "SP",
      name: "Sneha Patil",
      location: "Pune, MH",
      experience: "5 Years",
      noticePeriod: "30 Days",
      jobType: "Full-time",
      education: "MCA - Pune University",
      address: "Kothrud, Pune",
      expectedCtc: "₹10 - 12 LPA",
      skills: ["Angular", "Node.js", "MySQL"],
      matchPercent: 0.87,
      imageUrl: "https://images.unsplash.com/photo-1589156280159-27698a70f29e?q=80&w=600&auto=format&fit=crop",
    ),
    CandidateProfile(
      initials: "RK",
      name: "Rohan Kulkarni",
      location: "Nagpur, MH",
      experience: "3 Years",
      noticePeriod: "15 Days",
      jobType: "Full-time",
      education: "B.E. - RTMNU Nagpur",
      address: "Dharampeth, Nagpur",
      expectedCtc: "₹6 - 8 LPA",
      skills: ["Flutter", "Dart", "Firebase"],
      matchPercent: 0.78,
      imageUrl: "https://images.unsplash.com/photo-1566492031773-4f4e44671857?q=80&w=600&auto=format&fit=crop",
    ),
    CandidateProfile(
      initials: "AS",
      name: "Aditi Sharma",
      location: "Mumbai, MH",
      experience: "4 Years",
      noticePeriod: "Immediate",
      jobType: "Contract",
      education: "MCA - Mumbai University",
      address: "Andheri West, Mumbai",
      expectedCtc: "₹8 - 10 LPA",
      skills: ["React", "JavaScript", "MongoDB"],
      matchPercent: 0.72,
      imageUrl: "https://images.unsplash.com/photo-1614283233556-f35b0c801ef1?q=80&w=600&auto=format&fit=crop",
    ),
    CandidateProfile(
      initials: "VJ",
      name: "Vikram Joshi",
      location: "Nashik, MH",
      experience: "6 Years",
      noticePeriod: "45 Days",
      jobType: "Full-time",
      education: "B.Tech - Pune University",
      address: "College Road, Nashik",
      expectedCtc: "₹12 - 15 LPA",
      skills: ["Java", "Spring Boot", "AWS"],
      matchPercent: 0.91,
      imageUrl: "https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?q=80&w=600&auto=format&fit=crop",
    ),
    CandidateProfile(
      initials: "PD",
      name: "Priya Deshmukh",
      location: "Nagpur, MH",
      experience: "2 Years",
      noticePeriod: "30 Days",
      jobType: "Full-time",
      education: "MCA - Nagpur University",
      address: "Sadar, Nagpur",
      expectedCtc: "₹4.5 - 6 LPA",
      skills: ["Flutter", "Kotlin", "REST API"],
      matchPercent: 0.65,
      imageUrl: "https://images.unsplash.com/photo-1602442787305-decbd65be507?q=80&w=600&auto=format&fit=crop",
    ),
  ];

  late List<CandidateProfile> _stack;

  // Keeps track of removed candidates so the undo button can restore them
  final List<CandidateProfile> _removedHistory = [];

  // Drag state
  Offset _dragOffset = Offset.zero;
  double _angle = 0;
  bool _isDragging = false;

  // Overlay label opacity (SHORTLIST / REJECT)
  double _shortlistOpacity = 0;
  double _rejectOpacity = 0;

  static const double _swipeThreshold = 120;

  @override
  void initState() {
    super.initState();
    _stack = List.from(_candidates);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _angle = _dragOffset.dx / 300; // subtle rotation
      if (_dragOffset.dx > 0) {
        _shortlistOpacity = (_dragOffset.dx / _swipeThreshold).clamp(0, 1);
        _rejectOpacity = 0;
      } else {
        _rejectOpacity = (-_dragOffset.dx / _swipeThreshold).clamp(0, 1);
        _shortlistOpacity = 0;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset.dx > _swipeThreshold) {
      _completeSwipe(isRight: true); // shortlist
    } else if (_dragOffset.dx < -_swipeThreshold) {
      _completeSwipe(isRight: false); // reject
    } else {
      // snap back
      setState(() {
        _isDragging = false;
        _dragOffset = Offset.zero;
        _angle = 0;
        _shortlistOpacity = 0;
        _rejectOpacity = 0;
      });
    }
  }

  void _completeSwipe({required bool isRight}) {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _dragOffset = Offset(
        isRight ? screenWidth * 1.5 : -screenWidth * 1.5,
        _dragOffset.dy,
      );
      _isDragging = false;
    });

    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        if (_stack.isNotEmpty) {
          final removed = _stack.removeLast();
          _removedHistory.add(removed); // 👈 save for undo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 700),
              behavior: SnackBarBehavior.floating,
              backgroundColor: isRight ? AppColors.success : AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              content: Text(
                isRight
                    ? "Shortlisted ${removed.name}"
                    : "Rejected ${removed.name}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
        _dragOffset = Offset.zero;
        _angle = 0;
        _shortlistOpacity = 0;
        _rejectOpacity = 0;
      });
    });
  }

  void _buttonSwipe({required bool isRight}) {
    if (_stack.isEmpty) return;
    setState(() {
      _dragOffset = Offset(isRight ? 40 : -40, 0);
    });
    _completeSwipe(isRight: isRight);
  }

  void _undoSwipe() {
    if (_removedHistory.isEmpty) return;
    setState(() {
      _stack.add(_removedHistory.removeLast());
      _dragOffset = Offset.zero;
      _angle = 0;
      _shortlistOpacity = 0;
      _rejectOpacity = 0;
    });
  }

  void _resetStack() {
    setState(() {
      _stack = List.from(_candidates);
      _removedHistory.clear();
      _dragOffset = Offset.zero;
      _angle = 0;
      _shortlistOpacity = 0;
      _rejectOpacity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/hihr.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EmployeeDashboardPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.keyboard_double_arrow_left_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _stack.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (int i = 0; i < _stack.length; i++) _buildCard(i),
                      ],
                    ),
                  ),
          ),
          if (_stack.isNotEmpty) _buildActionButtons(),
          const SizedBox(height: 18),
        ],
      ),
      bottomNavigationBar: _buildBottomDock(),
    );
  }

  Widget _buildBottomDock() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border.withOpacity(0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.style_rounded, "Cards", isSelected: true),
              _buildNavItem(1, Icons.dashboard_rounded, "Dashboard"),
              _buildNavItem(2, Icons.work_rounded, "Jobs"),
              _buildNavItem(3, Icons.description_rounded, "Applications"),
              _buildNavItem(4, Icons.person_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool isSelected = false}) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isSelected) return;
          Widget nextPage;
          switch (index) {
            case 0:
              return;
            case 1:
              nextPage = const EmployeeDashboardPage();
              break;
            case 2:
              nextPage = const AllJobsPage();
              break;
            case 3:
              nextPage = const EmployeeApplicationPage();
              break;
            case 4:
              nextPage = const EmployeeCompanyProfilePage();
              break;
            default:
              return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.mainGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No more candidates right now",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You've gone through all available profiles",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _resetStack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Reload Candidates",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final isTopCard = index == _stack.length - 1;
    final candidate = _stack[index];

    // Slight stacked scale/offset for cards behind top card
    final depth = (_stack.length - 1) - index;
    final scale = 1 - (depth * 0.045).clamp(0.0, 0.09);
    final topOffset = depth * 12.0;

    Widget card = _CandidateCard(candidate: candidate);

    if (isTopCard) {
      return AnimatedContainer(
        duration: _isDragging
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx, _dragOffset.dy)
          ..rotateZ(_angle),
        transformAlignment: Alignment.center,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            children: [
              card,
              // SHORTLIST stamp (right swipe)
              Positioned(
                top: 40,
                left: 24,
                child: Opacity(
                  opacity: _shortlistOpacity,
                  child: Transform.rotate(
                    angle: -pi / 12,
                    child: _stampLabel("SHORTLIST", AppColors.success),
                  ),
                ),
              ),
              // REJECT stamp (left swipe)
              Positioned(
                top: 40,
                right: 24,
                child: Opacity(
                  opacity: _rejectOpacity,
                  child: Transform.rotate(
                    angle: pi / 12,
                    child: _stampLabel("REJECT", AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Cards underneath — static, slightly scaled/shifted
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      transform: Matrix4.identity()
        ..translate(0.0, topOffset)
        ..scale(scale),
      transformAlignment: Alignment.center,
      child: card,
    );
  }

  Widget _stampLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.9),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
          icon: Icons.close_rounded,
          color: AppColors.error,
          size: 56,
          iconSize: 26,
          onTap: () => _buttonSwipe(isRight: false), // reject
        ),
        const SizedBox(width: 56), // spacer between the two buttons
        _circleButton(
          icon: Icons.favorite_rounded,
          color: AppColors.success,
          size: 56,
          iconSize: 26,
          onTap: () => _buttonSwipe(isRight: true), // shortlist
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
    double iconSize = 26,
    bool useGradient = false, // 👈 when true, styled like the appbar
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: useGradient ? null : Colors.white,
          gradient: useGradient ? AppColors.mainGradient : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: useGradient ? AppColors.buttonText : color,
          size: iconSize,
        ),
      ),
    );
  }
}


class _CandidateCard extends StatelessWidget {
  final CandidateProfile candidate;

  const _CandidateCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Premium gradient background instead of photo
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.mainGradient,
                  ),
                ),

                // Match badge (top-right)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${(candidate.matchPercent * 100).round()}% Match",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Name + location + tags overlay
                Positioned(
                  left: 20,
                  bottom: 18,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black45),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 15,
                            color: AppColors.lime,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            candidate.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _pillTag(
                            Icons.work_history_rounded,
                            candidate.experience,
                          ),
                          const SizedBox(width: 8),
                          _pillTag(
                            Icons.event_available_rounded,
                            candidate.noticePeriod,
                          ),
                          const SizedBox(width: 8),
                          _pillTag(
                            Icons.access_time_filled_rounded,
                            candidate.jobType,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom info section
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoRow(
                    Icons.school_rounded,
                    "Education",
                    candidate.education,
                  ),
                  _infoRow(Icons.home_rounded, "Address", candidate.address),
                  _infoRow(
                    Icons.currency_rupee_rounded,
                    "Expected CTC",
                    candidate.expectedCtc,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.code_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: candidate.skills
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.lime.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.lime.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    skill,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Profile Match",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "${(candidate.matchPercent * 100).round()}%",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: candidate.matchPercent,
                          minHeight: 7,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  // Resume row
                  Row(
                    children: [
                      Icon(
                        Icons.description_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          candidate.resumeAttached
                              ? "Resume attached"
                              : "No resume",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (candidate.resumeAttached)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EmployeeViewResumePage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: const BoxDecoration(
                              gradient: AppColors.mainGradient,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.remove_red_eye_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "View",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
