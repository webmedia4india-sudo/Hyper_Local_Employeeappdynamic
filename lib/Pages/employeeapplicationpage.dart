import 'package:flutter/material.dart';
import 'package:hyper_local_employee/Pages/employeecomapanyprofilepage.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationdetailspage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeApplicationPage extends StatefulWidget {
  const EmployeeApplicationPage({super.key});

  @override
  State<EmployeeApplicationPage> createState() =>
      _EmployeeApplicationPageState();
}

class _EmployeeApplicationPageState extends State<EmployeeApplicationPage> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'All', 'count': 156},
    {'label': 'New', 'count': 32},
    {'label': 'Reviewed', 'count': 45},
  ];

  final List<Map<String, dynamic>> _applications = const [
    {
      'name': 'Rahul Verma',
      'role': 'Flutter Developer',
      'appliedOn': 'Applied on 12 May, 10:30 AM',
      'status': 'New',
    },
    {
      'name': 'Sunil Yadav',
      'role': 'Backend Developer',
      'appliedOn': 'Applied on 12 May, 09:15 AM',
      'status': 'Reviewed',
    },
    {
      'name': 'Amit Singh',
      'role': 'UI/UX Designer',
      'appliedOn': 'Applied on 11 May, 07:45 PM',
      'status': 'Shortlisted',
    },
    {
      'name': 'Vikas Pawar',
      'role': 'DevOps Engineer',
      'appliedOn': 'Applied on 11 May, 04:20 PM',
      'status': 'Interview',
    },
  ];

  // Status -> (background, text) colors
  static const Color _statusNew = Color(0xFF3B82F6);

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return _statusNew;
      case 'Reviewed':
      case 'Shortlisted':
        return AppColors.mint;
      case 'Interview':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
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
            onPressed: () {
              // hook up export / share action here
            },
            icon: const Icon(Icons.ios_share_rounded, color: AppColors.buttonText),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabRow(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                return _buildApplicationCard(_applications[index]);
              },
            ),
          ),
          _buildFilterSortBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomDock(),
    );
  }

  // ── STATUS TAB ROW (All / New / Reviewed) ──
  Widget _buildTabRow() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final bool isActive = _selectedTab == index;
          final tab = _tabs[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── APPLICATION CARD ──
  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final Color statusColor = _statusColor(app['status'] as String);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeApplicationDetailsPage(application: app),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app['role'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    app['appliedOn'] as String,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                app['status'] as String,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
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
              icon: const Icon(Icons.filter_alt_outlined,
                  color: AppColors.primary, size: 18),
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
              icon: const Icon(Icons.swap_vert_rounded,
                  color: AppColors.primary, size: 18),
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
              _buildDockItem(Icons.style_rounded, "Cards", 0, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeHomePage()),
                );
              }),
              _buildDockItem(Icons.dashboard_rounded, "Dashboard", 1, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeDashboardPage()),
                );
              }),
              _buildDockItem(Icons.work_rounded, "Jobs", 2, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllJobsPage()),
                );
              }),
              _buildDockItem(Icons.description_rounded, "Applications", 3, onTap: () {
                // Already on Applications page
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
    final bool isActive = index == 3; // Applications is index 3 and active on this page
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
}