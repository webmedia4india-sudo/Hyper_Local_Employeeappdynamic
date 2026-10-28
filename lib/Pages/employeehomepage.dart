import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hyper_local_employee/models/candidate_card_model.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/services/user_session.dart';

import 'package:hyper_local_employee/Pages/candidatedetailspage.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationpage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/Pages/employeecomapanyprofilepage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage>
    with SingleTickerProviderStateMixin {
  List<CandidateCardModel> _candidates = [];
  bool _loading = true;
  String? _error;
  int _currentIndex = 0;

  // Drag & Swipe state
  Offset _dragOffset = Offset.zero;
  double _angle = 0;
  bool _isDragging = false;
  bool _isSwiping = false;

  // Overlay stamp opacity (SHORTLIST / REJECT)
  double _shortlistOpacity = 0;
  double _rejectOpacity = 0;

  static const double _swipeThreshold = 120;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      int? employerId = prefs.getInt('employer_id');
      if (employerId == null) {
        final raw = prefs.get('employer_id');
        if (raw != null) {
          employerId = int.tryParse(raw.toString());
        }
      }
      employerId ??= prefs.getInt('employee_id');
      if (employerId == null && UserSession.currentEmployee != null) {
        employerId = UserSession.currentEmployee!.id;
      }
      employerId ??= 1;

      final candidates = await ApiService.getCandidateCards(employerId);
      if (!mounted) return;

      setState(() {
        _candidates = candidates;
        _currentIndex = 0;
        _loading = false;
        _dragOffset = Offset.zero;
        _angle = 0;
        _shortlistOpacity = 0;
        _rejectOpacity = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _swipe(String status, {bool isRightGesture = false}) async {
    if (_isSwiping || _currentIndex >= _candidates.length) return;

    final candidate = _candidates[_currentIndex];
    final isRight = status == 'shortlisted';

    setState(() {
      _isSwiping = true;
      if (!isRightGesture) {
        _dragOffset = Offset(isRight ? 60 : -60, 0);
        _angle = _dragOffset.dx / 300;
        _shortlistOpacity = isRight ? 0.8 : 0;
        _rejectOpacity = isRight ? 0 : 0.8;
      }
    });

    try {
      final success = await ApiService.updateApplicationStatus(
        candidate.applicationId,
        status,
      );

      if (!mounted) return;

      if (success) {
        final screenWidth = MediaQuery.of(context).size.width;
        setState(() {
          _dragOffset = Offset(
            isRight ? screenWidth * 1.5 : -screenWidth * 1.5,
            _dragOffset.dy,
          );
        });

        await Future.delayed(const Duration(milliseconds: 200));

        if (!mounted) return;

        setState(() {
          _candidates.removeWhere(
            (c) => c.applicationId == candidate.applicationId,
          );
          if (_currentIndex >= _candidates.length) {
            _currentIndex = max(0, _candidates.length - 1);
          }
          _dragOffset = Offset.zero;
          _angle = 0;
          _shortlistOpacity = 0;
          _rejectOpacity = 0;
          _isSwiping = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isRight ? AppColors.success : AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Text(
              isRight
                  ? "Shortlisted ${candidate.name}"
                  : "Rejected ${candidate.name}",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else {
        _snapBackWithError('Failed to update application status.');
      }
    } catch (e) {
      if (!mounted) return;
      _snapBackWithError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _snapBackWithError(String errorMsg) {
    setState(() {
      _dragOffset = Offset.zero;
      _angle = 0;
      _shortlistOpacity = 0;
      _rejectOpacity = 0;
      _isSwiping = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          errorMsg,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (_isSwiping) return;
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isSwiping) return;
    setState(() {
      _dragOffset += details.delta;
      _angle = _dragOffset.dx / 300;
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
    if (_isSwiping) return;
    if (_dragOffset.dx > _swipeThreshold) {
      _swipe('shortlisted', isRightGesture: true);
    } else if (_dragOffset.dx < -_swipeThreshold) {
      _swipe('rejected', isRightGesture: true);
    } else {
      setState(() {
        _isDragging = false;
        _dragOffset = Offset.zero;
        _angle = 0;
        _shortlistOpacity = 0;
        _rejectOpacity = 0;
      });
    }
  }

  void _openCandidateDetails(CandidateCardModel candidate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateDetailsPage(
          applicationId: candidate.applicationId,
          initialCandidate: candidate,
        ),
      ),
    );
  }

  Future<void> _openResume(CandidateCardModel c) async {
    if (c.resumeFile == null || c.resumeFile!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No resume file attached', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String urlStr;
    if (c.resumeFile!.startsWith('http://') || c.resumeFile!.startsWith('https://')) {
      urlStr = c.resumeFile!;
    } else {
      final cleanBase = ApiService.baseUrl.endsWith('/')
          ? ApiService.baseUrl.substring(0, ApiService.baseUrl.length - 1)
          : ApiService.baseUrl;
      final cleanPath = c.resumeFile!.startsWith('/')
          ? c.resumeFile!.substring(1)
          : c.resumeFile!;
      urlStr = '$cleanBase/$cleanPath';
    }

    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open resume ($urlStr)', style: GoogleFonts.poppins()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open resume: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                        'assets/images/new_onboarding_logo.png',
                        width: 80,
                        height: 80,
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
                                Icons.keyboard_double_arrow_right_rounded,
                                color: AppColors.primary,
                                size: 30,
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
            child: _buildMainContent(),
          ),
          if (!_loading && _error == null && _currentIndex < _candidates.length)
            _buildActionButtons(),
          const SizedBox(height: 18),
        ],
      ),
      bottomNavigationBar: _buildBottomDock(),
    );
  }

  Widget _buildMainContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 54,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                "Something went wrong",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
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
                  onPressed: _loadCandidates,
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
                  child: Text(
                    "Retry",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_candidates.isEmpty || _currentIndex >= _candidates.length) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background card underneath (if available)
          if (_currentIndex + 1 < _candidates.length)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              transform: Matrix4.identity()
                ..translate(0.0, 12.0)
                ..scale(0.955),
              transformAlignment: Alignment.center,
              child: _buildCandidateCard(
                _candidates[_currentIndex + 1],
                onViewResume: () => _openCandidateDetails(_candidates[_currentIndex + 1]),
              ),
            ),

          // Active top card
          AnimatedContainer(
            duration: _isDragging ? Duration.zero : const Duration(milliseconds: 220),
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
                  _buildCandidateCard(
                    _candidates[_currentIndex],
                    onViewResume: () => _openCandidateDetails(_candidates[_currentIndex]),
                  ),
                  // SHORTLIST stamp
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
                  // REJECT stamp
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
          ),
        ],
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
            "No new applicants right now",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You've gone through all available candidates",
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
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
              onPressed: _loadCandidates,
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
              child: Text(
                "Refresh",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(CandidateCardModel c, {VoidCallback? onViewResume}) {
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
          // Blue Gradient Top Section
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.mainGradient,
                  ),
                ),

                // Green "xx% Match" badge top right
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
                          "${c.matchPercentage.round()}% Match",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Name, location row with lime pin icon, white-translucent chips
                Positioned(
                  left: 20,
                  bottom: 18,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          shadows: const [
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
                          Expanded(
                            child: Text(
                              c.address.isNotEmpty ? c.address : "Location not specified",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (c.experienceYears > 0) ...[
                              _pillTag(
                                Icons.work_history_rounded,
                                c.experienceText,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (c.noticePeriodDays > 0) ...[
                              _pillTag(
                                Icons.event_available_rounded,
                                c.noticeText,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (c.employmentType.isNotEmpty)
                              _pillTag(
                                Icons.access_time_filled_rounded,
                                c.employmentType,
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

          // White section with Education, Address, Expected CTC rows, lime skill chips, Profile Match label with green percentage and progress bar, divider, Resume attached row
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
                    c.education.isNotEmpty ? c.education : "Not specified",
                  ),
                  _infoRow(
                    Icons.home_rounded,
                    "Address",
                    c.address.isNotEmpty ? c.address : "Not specified",
                  ),
                  _infoRow(
                    Icons.currency_rupee_rounded,
                    "Expected CTC",
                    c.ctcText,
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
                        child: c.skills.isEmpty
                            ? Text(
                                "No skills listed",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            : Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: c.skills
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
                                          style: GoogleFonts.poppins(
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
                          Text(
                            "Profile Match",
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "${c.matchPercentage.round()}%",
                            style: GoogleFonts.poppins(
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
                          value: (c.matchPercentage / 100.0).clamp(0.0, 1.0),
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
                  // Resume attached row
                  Row(
                    children: [
                      const Icon(
                        Icons.description_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.hasResume ? "Resume attached" : "No resume",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (c.hasResume)
                        GestureDetector(
                          onTap: onViewResume,
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.remove_red_eye_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "View",
                                  style: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
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
        style: GoogleFonts.poppins(
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
          onTap: _isSwiping ? () {} : () => _swipe('rejected'),
        ),
        const SizedBox(width: 56),
        _circleButton(
          icon: Icons.favorite_rounded,
          color: AppColors.success,
          size: 56,
          iconSize: 26,
          onTap: _isSwiping ? () {} : () => _swipe('shortlisted'),
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
    bool useGradient = false,
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
                style: GoogleFonts.poppins(
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
}
