import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/Pages/employeeaijobdescriptionpage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationpage.dart';
import 'package:hyper_local_employee/Pages/employeebusinessownerpage.dart';
import 'package:hyper_local_employee/Pages/employeecandidatesprofilepage.dart';
import 'package:hyper_local_employee/Pages/employeecomapanyprofilepage.dart';
import 'package:hyper_local_employee/Pages/employeecurrentplanpage.dart';
import 'package:hyper_local_employee/Pages/employeehiringdashboardpage.dart';
import 'package:hyper_local_employee/Pages/employeehiringmappage.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/Pages/employeeinterviewerpage.dart';
import 'package:hyper_local_employee/Pages/employeeinterviewschedulepage.dart';
import 'package:hyper_local_employee/Pages/employeenearbycandidatespage.dart';
import 'package:hyper_local_employee/Pages/employeenotificationpage.dart';
import 'package:hyper_local_employee/Pages/employeeoffercoverpage.dart';
import 'package:hyper_local_employee/Pages/employeepaymentpage.dart';
import 'package:hyper_local_employee/Pages/employeepostnewjobpage.dart';
import 'package:hyper_local_employee/Pages/employeerecruiterpage.dart';
import 'package:hyper_local_employee/Pages/employeesettingpage.dart';
import 'package:hyper_local_employee/Pages/employeewalkininterviewpage.dart';
import 'package:hyper_local_employee/Splash/employeeloginpage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TapScale({super.key, required this.child, this.onTap});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  double _scale = 1.0;

  void _setScale(double v) => setState(() => _scale = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.94),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  final int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Search query state
  String _searchQuery = "";
  bool _isSearchFocused = false;

  // Selected filter state
  final String _timeFilter = "This Month";

  // Mock candidates database for local Nagpur search
  final List<Map<String, String>> _candidates = [
    {
      "name": "Rahul Sharma",
      "role": "Flutter Developer",
      "skills": "Flutter, Dart, Firebase, REST APIs",
      "exp": "3.5 Years",
      "location": "Nagpur, MH",
    },
    {
      "name": "Priya Patel",
      "role": "UI/UX Designer",
      "skills": "Figma, Sketch, Adobe XD, Wireframing",
      "exp": "2.2 Years",
      "location": "Nagpur, MH",
    },
    {
      "name": "Amit Verma",
      "role": "Backend Developer",
      "skills": "Java, Spring Boot, Microservices, MySQL",
      "exp": "5.0 Years",
      "location": "Nagpur, MH",
    },
    {
      "name": "Sneha Deshmukh",
      "role": "React JS Developer",
      "skills": "React.js, Redux, HTML5, CSS3, Tailwind",
      "exp": "4.1 Years",
      "location": "Nagpur, MH",
    },
    {
      "name": "Vijay Kamble",
      "role": "DevOps Specialist",
      "skills": "Docker, Kubernetes, Jenkins, AWS, CI/CD",
      "exp": "3.0 Years",
      "location": "Nagpur, MH",
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 950;
    final bool isSearching = _searchQuery.isNotEmpty;

    // Filter candidates based on search query
    final filteredCandidates = _candidates.where((c) {
      final q = _searchQuery.toLowerCase();
      return c['name']!.toLowerCase().contains(q) ||
          c['role']!.toLowerCase().contains(q) ||
          c['skills']!.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      drawer: isWideScreen
          ? null
          : Drawer(
              width: 235,
              backgroundColor: Colors.white,
              child: _buildDrawerContent(),
            ),
      body: Row(
        children: [
          if (isWideScreen)
            Container(
              width: 235,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: _buildDrawerContent(),
            ),
          Expanded(
            child: Column(
              children: [
                if (isWideScreen)
                  _buildWebTopBar()
                else
                  _buildMobilePremiumHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isWideScreen ? 24 : 12,
          isWideScreen ? 12 : 8,
          isWideScreen ? 24 : 12,
          isWideScreen ? 12 : 16, // Reduced bottom spacing
        ),
                        child: isSearching
                            ? _buildSearchResults(filteredCandidates)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isWideScreen)
                                    _buildWelcomeAndSubscriptionHeader(
                                      isWideScreen,
                                    )
                                  else
                                    _buildSubscriptionHeaderMobileOnly(),
                                  const SizedBox(
                                    height: 5,
                                  ), // Even tighter spacing
                                  _buildKPICardsGrid(isWideScreen),
                                  const SizedBox(
                                    height: 5,
                                  ), // Even tighter spacing
                                  _buildQuickActionsSection(isWideScreen),
                                  const SizedBox(
                                    height: 5,
                                  ), // Even tighter spacing
                                  _buildRecruitmentSummarySection(isWideScreen),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildBottomDock(),
    );
  }

  // ── CANDIDATE SEARCH RESULTS OVERLAY WIDGET ──
  Widget _buildSearchResults(List<Map<String, String>> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: 'Search Results ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: '(${results.length})',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = "");
              },
              child: Text(
                "Clear Search",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (results.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 40,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No candidates match your search query.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, idx) {
              final c = results[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_search_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                c['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.limeSoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c['exp']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.5,
                                    color: AppColors.primaryDeep,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            c['role']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Skills: ${c['skills']!}",
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.textSecondary,
                                size: 9,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                c['location']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ── WEB TOP BAR (WIDE SCREEN) ──
  Widget _buildWebTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (!_isSearchFocused) {
                setState(() {
                  _isSearchFocused = true;
                });
                _searchFocusNode.requestFocus();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: (_isSearchFocused || _searchQuery.isNotEmpty) ? 380 : 38,
              child: _buildSearchField(),
            ),
          ),
          const Spacer(),
          _buildNotificationIcon(darkTheme: true),
          const SizedBox(width: 16),
          _buildAvatarWidget(size: 34),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final bool hasQuery = _searchQuery.isNotEmpty;
    final bool isCollapsed = !_isSearchFocused && !hasQuery;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCollapsed ? 19 : 10),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isCollapsed
          ? const Center(
              child: Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 18,
              ),
            )
          : TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search candidates, resumes, skills...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
    );
  }

  Widget _buildNotificationIcon({bool darkTheme = false}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeNotificationPage()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: darkTheme ? AppColors.textSecondary : Colors.white,
              size: 24,
            ),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: darkTheme ? Colors.white : AppColors.primaryDeep,
                    width: 1.2,
                  ),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWidget({double size = 34}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeCompanyProfilePage()),
        );
      },
      borderRadius: BorderRadius.circular(size),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primaryDeep,
                size: size * 0.65,
              ),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: AppColors.lime,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── MOBILE PREMIUM HEADER (MATCHING THE SCREENSHOT) ──
  Widget _buildMobilePremiumHeader() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2CC2), // Rich cobalt blue
            Color(0xFF061570), // Deep royal blue
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hamburger menu
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Logo
                  Image.asset(
                    'assets/images/new_splash_logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Actions: Notifications
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeNotificationPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Location icon and city below it
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimatedLocationIcon(),
                      const SizedBox(height: 2),
                      Text(
                        "Amravati",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // User Greeting below top row
          Row(
            children: [
              Text(
                "Hi, Rahul",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text('👋', style: TextStyle(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (!_isSearchFocused) {
                  setState(() {
                    _isSearchFocused = true;
                  });
                  _searchFocusNode.requestFocus();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: (_isSearchFocused || _searchQuery.isNotEmpty)
                    ? MediaQuery.of(context).size.width - 32
                    : 44.0,
                child: _buildSearchFieldMobile(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FLOATING SEARCH FIELD FOR MOBILE HEADER ──
  Widget _buildSearchFieldMobile() {
    final bool hasQuery = _searchQuery.isNotEmpty;
    final bool isCollapsed = !_isSearchFocused && !hasQuery;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCollapsed ? 22 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCollapsed
          ? const Center(
              child: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            )
          : TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search jobs, skills, companies...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
    );
  }

  // ── COMPACT SUBSCRIPTION HEADER FOR MOBILE ──
  Widget _buildSubscriptionHeaderMobileOnly() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF9E6), Color(0xFFFFF1C2)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.30), width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Premium Plan active till 20 Aug 2025",
              style: GoogleFonts.poppins(
                color: Colors.amber.shade900,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeCurrentPlanPage(),
                ),
              );
            },
            child: Text(
              "Manage",
              style: GoogleFonts.poppins(
                color: Colors.amber.shade900,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── GREETINGS & SUBSCRIPTION HEADER (ATTRACTIVE STYLE) ──
  Widget _buildWelcomeAndSubscriptionHeader(bool isWideScreen) {
    final welcomeWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Welcome back,",
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.limeSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Nagpur Hub",
                  style: GoogleFonts.poppins(
                    fontSize: 8.0,
                    color: AppColors.primaryDeep,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Text(
                "Hi, TechNova Solutions!",
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  color: AppColors.primaryDeep,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Text('👋', style: TextStyle(fontSize: 13)),
            ],
          ),

          const SizedBox(height: 1),
          Text(
            "Here's your recruitment overview for today.",
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    final subWidget = Container(
      width: isWideScreen ? 310 : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF9E6), Color(0xFFFFF1C2)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.30), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.amber.shade700.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Premium Plan",
                      style: GoogleFonts.poppins(
                        color: Colors.amber.shade900,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Valid till 20 Aug 2025",
                      style: GoogleFonts.poppins(
                        color: Colors.amber.shade900.withOpacity(0.7),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmployeeCurrentPlanPage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Manage Subscription",
                            style: GoogleFonts.poppins(
                              color: Colors.amber.shade900,
                              fontSize: 9.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.amber.shade900,
                            size: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.amber.shade800,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Active",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 8.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: welcomeWidget),
          const SizedBox(width: 10),
          subWidget,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [welcomeWidget, const SizedBox(height: 6), subWidget],
      );
    }
  }

  // ── KPI CARDS GRID (SMALLER & COMPACT) ──
  Widget _buildKPICardsGrid(bool isWideScreen) {
    final kpis = [
      {
        'title': 'Active Jobs',
        'count': 12,
        'icon': Icons.work_rounded,
        'color': AppColors.primary,
        'trend': '↑ 2 last week',
        'isTrendPositive': true,
      },
      {
        'title': 'Total Applications',
        'count': 152,
        'icon': Icons.description_rounded,
        'color': Colors.blue,
        'trend': '↑ 18% last week',
        'isTrendPositive': true,
      },
      {
        'title': 'New Applications',
        'count': 48,
        'icon': Icons.assignment_late_rounded,
        'color': AppColors.coral,
        'trend': '↑ 18% last week',
        'isTrendPositive': true,
      },
      {
        'title': 'Shortlisted Candidates',
        'count': 15,
        'icon': Icons.fact_check_rounded,
        'color': AppColors.mint,
        'trend': '↑ 10% last week',
        'isTrendPositive': true,
      },
      {
        'title': 'Interviews Today',
        'count': 4,
        'icon': Icons.calendar_month_rounded,
        'color': AppColors.pink,
        'trend': '↑ 1 yesterday',
        'isTrendPositive': true,
      },
      {
        'title': 'Offers Pending',
        'count': 5,
        'icon': Icons.hourglass_top_rounded,
        'color': Colors.amber,
        'trend': '↓ 1 last week',
        'isTrendPositive': false,
      },
      {
        'title': 'Candidates Hired',
        'count': 8,
        'icon': Icons.emoji_events_rounded,
        'color': Colors.teal,
        'trend': '↑ 20% last month',
        'isTrendPositive': true,
      },
      {
        'title': 'Jobs Expiring Soon',
        'count': 3,
        'icon': Icons.warning_amber_rounded,
        'color': Colors.redAccent,
        'trend': 'View Jobs',
        'isTrendPositive': null,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero, // Remove default grid padding
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 cards per row on mobile & desktop
        crossAxisSpacing: isWideScreen ? 6 : 4, // kami kela (10/6 -> 6/4)
        mainAxisSpacing: isWideScreen ? 6 : 4, // kami kela
        childAspectRatio: isWideScreen
            ? 2.6
            : 1.15, // Aspect ratio adjusted for narrower 4-column layout with tight gap
      ),
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return _buildKPICard(
          title: kpi['title'] as String,
          count: kpi['count'] as int,
          icon: kpi['icon'] as IconData,
          color: kpi['color'] as Color,
          trend: kpi['trend'] as String,
          isTrendPositive: kpi['isTrendPositive'] as bool?,
        );
      },
    );
  }

  Widget _buildKPICard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required String trend,
    required bool? isTrendPositive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ), // Tighter padding for a smaller card
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Sleeker round corners
        border: Border.all(color: AppColors.border, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start, // Align to top/start to reduce gaps
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: color, size: 8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3), // Controlled small gap between Title and Count
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: count),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, val, _) {
              return Text(
                val.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12.5, // Smaller count size
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 3), // Controlled small gap between Count and Trend
          Row(
            children: [
              if (isTrendPositive == true) ...[
                const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.green,
                  size: 7,
                ),
                const SizedBox(width: 1),
              ] else if (isTrendPositive == false) ...[
                const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.redAccent,
                  size: 7,
                ),
                const SizedBox(width: 1),
              ],
              Expanded(
                child: isTrendPositive == null
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllJobsPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              trend,
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontSize: 7.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 1),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primary,
                              size: 6,
                            ),
                          ],
                        ),
                      )
                    : Text(
                        trend,
                        style: GoogleFonts.poppins(
                          color: isTrendPositive == true
                              ? Colors.green
                              : Colors.redAccent,
                          fontSize: 7.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS SECTION (LAHAN/COMPACT CARDS) ──
  Widget _buildQuickActionsSection(bool isWideScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero, // Remove default grid padding
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWideScreen ? 4 : 2,
          crossAxisSpacing: isWideScreen ? 10 : 6,
          mainAxisSpacing: isWideScreen ? 10 : 6,
          childAspectRatio: isWideScreen
              ? 2.85
              : 2.15, // Lower ratio gives more height to prevent overflow
          children: [
            _buildQuickActionCard(
              title: "Post Job",
              desc: "Create a job opening",
              icon: Icons.post_add_rounded,
              color: AppColors.primary,
              soft: const Color(0xFFDCE3FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeePostNewJobPage(),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              title: "Search Candidates",
              desc: "Find local talent",
              icon: Icons.person_search_rounded,
              color: AppColors.coral,
              soft: AppColors.coralSoft,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeHomePage()),
                );
              },
            ),
            _buildQuickActionCard(
              title: "View Applications",
              desc: "Review job applications",
              icon: Icons.description_rounded,
              color: AppColors.mint,
              soft: AppColors.mintSoft,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeApplicationPage(),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              title: "Schedule Interview",
              desc: "Plan candidate interviews",
              icon: Icons.calendar_month_rounded,
              color: AppColors.pink,
              soft: AppColors.pinkSoft,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeInterviewSchedulePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required Color soft,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ), // Tighter padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Sleeker round corners
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: soft.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.12),
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: color, size: 12),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── RECRUITMENT SUMMARY & SIDE-BY-SIDE CHARTS ──
  Widget _buildRecruitmentSummarySection(bool isWideScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recruitment Summary",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Row(
                children: [
                  Text(
                    _timeFilter,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Mini KPI Row (Attractive Color Styling)
       SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  physics: const BouncingScrollPhysics(),
  child: Row(
    children: [
      _buildMiniKPIItem(
        "Active Jobs",
        12,
        AppColors.primary,
        AppColors.primary.withOpacity(0.04),
      ),
      _buildMiniKPIItem(
        "New Applications",
        48,
        AppColors.coral,
        AppColors.coralSoft.withOpacity(0.3),
      ),
      _buildMiniKPIItem(
        "Shortlisted",
        15,
        AppColors.mint,
        AppColors.mintSoft.withOpacity(0.3),
      ),
      _buildMiniKPIItem(
        "Interviews Today",
        4,
        AppColors.pink,
        AppColors.pinkSoft.withOpacity(0.3),
      ),
      _buildMiniKPIItem(
        "Hired This Month",
        8,
        Colors.teal,
        Colors.teal.withOpacity(0.04),
      ),
    ],
  ),
),
        const SizedBox(height: 14),

        // ALWAYS Side-by-Side Charts (even on mobile)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _buildDoughnutChartWidget(isMobile: !isWideScreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: _buildLineChartWidget(isMobile: !isWideScreen),
            ),
          ],
        ),

        const SizedBox(height: 14),
        // Footer report banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF3FE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.10),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "You're doing great with your hiring this month.",
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryDeep,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      "Full Report",
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniKPIItem(
  String title,
  int count,
  Color statusColor,
  Color bgColor,
) {
  return Container(
    width: 165, // 130 -> 165 (mothi card)
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(16), // 11 -> 16
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: statusColor.withOpacity(0.18), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: statusColor.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 26, // 18 -> 26
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13, // 10.5 -> 13
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          width: 36, // 28 -> 36
          height: 4, // 3 -> 4
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildDoughnutChartWidget({required bool isMobile}) {
    final segments = [
      DoughnutChartSegment("New", 48, AppColors.coral),
      DoughnutChartSegment("Shortlisted", 15, AppColors.mint),
      DoughnutChartSegment("Interviews", 4, AppColors.pink),
      DoughnutChartSegment("Offers", 5, Colors.amber),
      DoughnutChartSegment("Hired", 8, Colors.teal),
      DoughnutChartSegment("Others", 72, Colors.blue),
    ];

    final chartSize = isMobile ? 80.0 : 120.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          isMobile
              ? Column(
                  children: [
                    SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: CustomPaint(
                        painter: _DoughnutChartPainter(
                          segments: segments,
                          isMobile: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: segments.take(4).map((seg) {
                        final double pct = (seg.value / 152.0) * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: seg.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  seg.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 7.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "${pct.toStringAsFixed(0)}%",
                                style: GoogleFonts.poppins(
                                  fontSize: 7.5,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: CustomPaint(
                        painter: _DoughnutChartPainter(
                          segments: segments,
                          isMobile: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: segments.map((seg) {
                          final double pct = (seg.value / 152.0) * 100;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: seg.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    seg.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${seg.value.round()} (${pct.toStringAsFixed(0)}%)",
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildLineChartWidget({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trend",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Text(
                      "Weekly",
                      style: GoogleFonts.poppins(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 1),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: isMobile
                ? 90
                : 130, // Shorter height for mobile side-by-side
            width: double.infinity,
            child: CustomPaint(painter: _LineChartPainter(isMobile: isMobile)),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM DOCK NAVIGATION BAR (FOR MOBILE SCREEN) ──
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
              _buildDockItem(Icons.style_rounded, "Cards", 0, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeHomePage()),
                );
              }),
              _buildDockItem(Icons.dashboard_rounded, "Dashboard", 1, onTap: () {
                // Already on Dashboard
              }),
              _buildDockItem(Icons.work_rounded, "Jobs", 2, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllJobsPage()),
                );
              }),
              _buildDockItem(Icons.description_rounded, "Applications", 3, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeApplicationPage()),
                );
              }),
              _buildDockItem(Icons.person_rounded, "Profile", 4, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeCompanyProfilePage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(
    IconData icon,
    String label,
    int index, {
    required VoidCallback onTap,
  }) {
    final bool isActive = index == 1; // Dashboard is index 1 and active on this page
    final Color color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
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
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SIDE DRAWER CONTENT (RESTORED OLD SIDEBAR) ──
  Widget _buildDrawerContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDeep, AppColors.primaryDark],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.45),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://i.pravatar.cc/150?img=60',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Amit Kadam',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 1),
                      Text(
                        'amit.kadam@gmail.com',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // _drawerTile(
                  //   icon: Icons.home_outlined,
                  //   title: "Home",
                  //   onTap: () {},
                  // ),
                  _drawerTile(
                    icon: Icons.business_outlined,
                    title: "Company Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeCompanyProfilePage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.work_outline_rounded,
                    title: "All Jobs",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllJobsPage()),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.bookmark_border_rounded,
                    title: "Saved Jobs",
                    onTap: () {},
                  ),
                  _drawerTile(
                    icon: Icons.auto_awesome_rounded,
                    title: "AI Job Description",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeAiJobDescriptionPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.business_center_outlined,
                    title: "Business Owner",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeBusinessOwnerPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.badge_outlined,
                    title: "Recruiter",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeRecruiterPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.record_voice_over_outlined,
                    title: "Interviewer",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeInterviewerPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.person_search_rounded,
                    title: "Nearby Candidates",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeNearbyCandidatesPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.dashboard_outlined,
                    title: "Hiring Dashboard",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeHiringDashboardPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.map_outlined,
                    title: "Hiring Map",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeHiringMapPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.groups_outlined,
                    title: "Walk In Interview",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeWalkinInterviewPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.card_membership_outlined,
                    title: "Current Plan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeCurrentPlanPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.payment_outlined,
                    title: "Payment",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeePaymentPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.description_outlined,
                    title: "Offer Cover",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeOfferCoverPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.people_alt_outlined,
                    title: "Candidates Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeCandidateProfilePage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.assignment_outlined,
                    title: "My Applications",
                    onTap: () {},
                  ),
                  _drawerTile(
                    icon: Icons.person_outline_rounded,
                    title: "My Profile",
                    onTap: () {},
                  ),
                  _drawerTile(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeSettingPage(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.help_outline_rounded,
                    title: "Help Center",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.divider, thickness: 1, height: 1),
          const SizedBox(height: 4),
          _drawerTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const EmployeeLoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── PLAIN DRAWER TILE ──
  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final Color iColor = iconColor ?? AppColors.primary;
    final Color iBg = iconColor != null
        ? iconColor.withOpacity(0.12)
        : AppColors.primary.withOpacity(0.08);

    return InkWell(
      onTap: () {
        try {
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        } catch (e) {
          // ignore when used in pinned sidebar
        }
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ), // More compact drawer padding
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CUSTOM DOUGHNUT CHART Segment & Painter ──
class DoughnutChartSegment {
  final String label;
  final double value;
  final Color color;
  DoughnutChartSegment(this.label, this.value, this.color);
}

class _DoughnutChartPainter extends CustomPainter {
  final List<DoughnutChartSegment> segments;
  final bool isMobile;

  _DoughnutChartPainter({required this.segments, required this.isMobile});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = segments.map((s) => s.value).fold(0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final strokeW = isMobile ? 12.0 : 18.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeW / 2 - 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    for (var segment in segments) {
      if (segment.value <= 0) continue;
      final sweepAngle = 2 * pi * (segment.value / total);
      paint.color = segment.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Central Title "152 Total"
    final textPainter1 = TextPainter(
      text: TextSpan(
        text: '152\n',
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: isMobile ? 13 : 16,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: isMobile ? 'Total' : 'Total\nApplications',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 6.5 : 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter1.layout(minWidth: 0, maxWidth: size.width);
    textPainter1.paint(
      canvas,
      Offset(
        center.dx - textPainter1.width / 2,
        center.dy - textPainter1.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── CUSTOM LINE CHART PAINTER (COMPACT FOR MOBILE ROW) ──
class _LineChartPainter extends CustomPainter {
  final bool isMobile;
  const _LineChartPainter({required this.isMobile});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final leftPadding = isMobile ? 16.0 : 26.0;
    final bottomPadding = isMobile ? 14.0 : 18.0;
    final chartWidth = width - leftPadding;
    final chartHeight = height - bottomPadding;

    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 0.8;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMobile ? 2 : 3;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.18),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(leftPadding, 0, width, chartHeight));

    // Data values matching the curve (values from 0 to 50)
    final List<double> data = [10, 22, 18, 30, 20, 32, 44];
    final List<String> labels = [
      "Apr 28",
      "May 5",
      "May 12",
      "May 19",
      "May 26",
    ];

    // Draw Y grid lines (3 steps instead of 5 on mobile)
    final int gridSteps = isMobile ? 3 : 5;
    for (int i = 0; i <= gridSteps; i++) {
      final y = chartHeight * (1 - i / gridSteps);
      canvas.drawLine(Offset(leftPadding, y), Offset(width, y), gridPaint);

      // Y Text
      final val = (i * (50 ~/ gridSteps)).toString();
      final textPainter = TextPainter(
        text: TextSpan(
          text: val,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: isMobile ? 7.0 : 8.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 4, y - textPainter.height / 2),
      );
    }

    // Coordinates points list
    final List<Offset> points = [];
    final double xSpacing = chartWidth / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      final px = leftPadding + (i * xSpacing);
      final py = chartHeight * (1 - data[i] / 50.0);
      points.add(Offset(px, py));
    }

    // Draw Line and Gradient Fill using path curves
    if (points.isNotEmpty) {
      final linePath = Path();
      linePath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        // Curved control points
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;

        linePath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          p1.dx,
          p1.dy,
        );
      }

      // Draw Gradient Path underneath
      final fillPath = Path.from(linePath);
      fillPath.lineTo(points.last.dx, chartHeight);
      fillPath.lineTo(points.first.dx, chartHeight);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);

      // Draw Main Line
      canvas.drawPath(linePath, linePaint);
    }

    // Draw Point Dots (only draw dots on desktop or small dots on mobile)
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var pt in points) {
      canvas.drawCircle(pt, isMobile ? 3 : 4, dotPaint);
      canvas.drawCircle(pt, isMobile ? 3 : 4, dotBorderPaint);
    }

    // Draw X labels
    final double labelSpacing = chartWidth / (labels.length - 1);
    for (int i = 0; i < labels.length; i++) {
      final lx = leftPadding + (i * labelSpacing);
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: isMobile ? 7.0 : 8.0,

            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(lx - textPainter.width / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedLocationIcon extends StatefulWidget {
  const AnimatedLocationIcon({super.key});

  @override
  State<AnimatedLocationIcon> createState() => _AnimatedLocationIconState();
}

class _AnimatedLocationIconState extends State<AnimatedLocationIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 24,
          ),
        );
      },
    );
  }
}
