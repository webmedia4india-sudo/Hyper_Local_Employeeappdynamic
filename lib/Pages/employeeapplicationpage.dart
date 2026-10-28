import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local_employee/Pages/candidatedetailspage.dart';
import 'package:hyper_local_employee/Pages/employeecomapanyprofilepage.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationdetailspage.dart';
import 'package:hyper_local_employee/Pages/employeeinterviewschedulepage.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/services/user_session.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeApplicationPage extends StatefulWidget {
  const EmployeeApplicationPage({super.key});

  @override
  State<EmployeeApplicationPage> createState() =>
      _EmployeeApplicationPageState();
}

class _EmployeeApplicationPageState extends State<EmployeeApplicationPage> {
  int _selectedTab =
      0; // 0: All (default), 1: Applied, 2: Shortlisted, 3: Rejected
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _allApplications = [];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
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

      final apps = await ApiService.getEmployerApplications(employerId);
      if (!mounted) return;

      setState(() {
        _allApplications = apps;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  int get _shortlistedCount => _allApplications
      .where(
        (a) =>
            (a['application_status'] ?? '').toString().toLowerCase() ==
            'shortlisted',
      )
      .length;

  int get _rejectedCount => _allApplications
      .where(
        (a) =>
            (a['application_status'] ?? '').toString().toLowerCase() ==
            'rejected',
      )
      .length;

  int get _appliedCount => _allApplications.where((a) {
    final st = (a['application_status'] ?? '').toString().toLowerCase();
    return st != 'shortlisted' && st != 'rejected';
  }).length;

  int get _allCount => _allApplications.length;

  List<Map<String, dynamic>> get _tabs => [
    {'label': 'All', 'count': _allCount},
    {'label': 'Applied', 'count': _appliedCount},
    {'label': 'Shortlisted', 'count': _shortlistedCount},
    {'label': 'Rejected', 'count': _rejectedCount},
  ];

  List<Map<String, dynamic>> get _filteredApplications {
    switch (_selectedTab) {
      case 1: // Applied / Pending
        return _allApplications.where((a) {
          final st = (a['application_status'] ?? '').toString().toLowerCase();
          return st != 'shortlisted' && st != 'rejected';
        }).toList();
      case 2: // Shortlisted
        return _allApplications
            .where(
              (a) =>
                  (a['application_status'] ?? '').toString().toLowerCase() ==
                  'shortlisted',
            )
            .toList();
      case 3: // Rejected
        return _allApplications
            .where(
              (a) =>
                  (a['application_status'] ?? '').toString().toLowerCase() ==
                  'rejected',
            )
            .toList();
      case 0: // All (Default)
      default:
        return _allApplications;
    }
  }

  // Status -> (background, text) colors
  static const Color _statusNew = Color(0xFF3B82F6);
  static const Color _statusRejected = Color(0xFFEF4444);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted':
        return AppColors.mint;
      case 'rejected':
        return _statusRejected;
      case 'new':
      case 'applied':
      case 'under_review':
        return _statusNew;
      case 'interview':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Applied';
    final clean = status.replaceAll('_', ' ').toLowerCase();
    return clean[0].toUpperCase() + clean.substring(1);
  }

  String _formatAppliedDate(dynamic rawDate) {
    if (rawDate == null) return 'Applied recently';
    final str = rawDate.toString().trim();
    if (str.startsWith('Applied')) return str;
    try {
      final dt = DateTime.parse(str);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      return 'Applied on $day $month, $year';
    } catch (_) {
      return 'Applied on $str';
    }
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
          "Applications",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadApplications,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.buttonText,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabRow(),
          Expanded(child: _buildBodyContent()),
          _buildFilterSortBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomDock(),
    );
  }

  Widget _buildBodyContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadApplications,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredList = _filteredApplications;

    if (filteredList.isEmpty) {
      final tabLabel = _tabs[_selectedTab]['label'];
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                color: AppColors.textSecondary.withOpacity(0.5),
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                'No $tabLabel applications found',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Applications swiped from card screen will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return _buildApplicationCard(filteredList[index]);
        },
      ),
    );
  }

  // ── STATUS TAB ROW (All / Applied / Shortlisted / Rejected) ──
  Widget _buildTabRow() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final bool isActive = _selectedTab == index;
            final tab = _tabs[index];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = index);
                  if (tab['label'] == 'Shortlisted') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeeInterviewSchedulePage(),
                      ),
                    ).then((_) => _loadApplications());
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${tab['label']} (${tab['count']})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _getCandidateInitials(Map<String, dynamic> app, String candidateName) {
    final firstName = (app['first_name'] ?? '').toString().trim();
    final lastName =
        (app['last_name'] ?? app['surname'] ?? '').toString().trim();
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return (firstName[0] + lastName[0]).toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    }

    final rawName = candidateName.trim();
    final effectiveName =
        (rawName.isEmpty || rawName.toLowerCase() == 'applicant')
            ? (app['user_name'] ?? app['candidate_name'] ?? app['name'] ?? rawName)
                .toString()
                .trim()
            : rawName;

    final parts = effectiveName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return 'A';
  }

  Widget _buildAvatarContent(String photoUrl, String initials) {
    final Widget initialsWidget = Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );

    if (photoUrl.isEmpty) {
      return initialsWidget;
    }

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => initialsWidget,
      ),
    );
  }

  // ── APPLICATION CARD ──
  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final rawStatus = (app['application_status'] ?? app['status'] ?? 'Applied')
        .toString();
    final String statusText = _formatStatus(rawStatus);
    final Color statusColor = _statusColor(rawStatus);

    final String name =
        (app['user_name'] ?? app['resume_name'] ?? app['name'] ?? 'Applicant')
            .toString();

    final rawPhoto = app['user_profile_photo'] ?? app['profile_photo'];
    final String photoStr = (rawPhoto ?? '').toString().trim();
    final bool hasPhoto =
        photoStr.isNotEmpty && photoStr.toLowerCase() != 'null';
    final String photoUrl =
        hasPhoto ? ApiService.resolveImageUrl(photoStr) : '';
    final String initials = _getCandidateInitials(app, name);

    final String role =
        (app['job_title'] ?? app['role'] ?? app['applied_for'] ?? 'Applied Job')
            .toString();

    final String appliedOn = _formatAppliedDate(
      app['applied_at'] ?? app['appliedOn'],
    );

    final dynamic rawAppId = app['application_id'] ?? app['id'];
    final parsedId =
        rawAppId != null ? int.tryParse(rawAppId.toString()) : null;
    final bool isShortlisted = rawStatus.toLowerCase() == 'shortlisted';

    return GestureDetector(
      onTap: () {
        if (rawAppId != null) {
          final parsedId = int.tryParse(rawAppId.toString());
          if (parsedId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CandidateDetailsPage(applicationId: parsedId),
              ),
            ).then((_) => _loadApplications());
            return;
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeApplicationDetailsPage(application: app),
          ),
        ).then((_) => _loadApplications());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _buildAvatarContent(photoUrl, initials),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    appliedOn,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: isShortlisted
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmployeeInterviewSchedulePage(
                                applicationId: parsedId,
                                candidate: app,
                              ),
                            ),
                          ).then((_) => _loadApplications());
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                if ((app['interview_response_status'] ?? '').toString().toLowerCase() == 'accepted') ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Accepted',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ] else if ((app['interview_response_status'] ?? '').toString().toLowerCase() == 'rejected') ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Rejected',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── FILTER / SORT BAR ──
  Widget _buildFilterSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // hook up filter sheet here

                
              },
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              label: const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // hook up sort options here
              },
              icon: const Icon(
                Icons.swap_vert_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              label: const Text(
                'Sort',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM DOCK NAVIGATION BAR ──
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
              _buildDockItem(
                Icons.style_rounded,
                "Cards",
                0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmployeeHomePage()),
                  );
                },
              ),
              _buildDockItem(
                Icons.dashboard_rounded,
                "Dashboard",
                1,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployeeDashboardPage(),
                    ),
                  );
                },
              ),
              _buildDockItem(
                Icons.work_rounded,
                "Jobs",
                2,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllJobsPage()),
                  );
                },
              ),
              _buildDockItem(
                Icons.description_rounded,
                "Applications",
                3,
                onTap: () {
                  // Already on Applications page
                },
              ),
              _buildDockItem(
                Icons.person_rounded,
                "Profile",
                4,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployeeCompanyProfilePage(),
                    ),
                  );
                },
              ),
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
    final bool isActive = index == 3;
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
              Icon(icon, color: color, size: 20),
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
}