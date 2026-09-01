import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_local_employee/Pages/employeecomapanyprofilepage.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationpage.dart';
import 'package:hyper_local_employee/Pages/employeepostnewjobpage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────
enum JobStatus { active, draft, expired, paused }

class JobPosting {
  final String title;
  final int applications;
  final double distanceKm;
  final JobStatus status;

  // ── Company related data ──
  final String companyName;
  final String companyLocation; // e.g. area/city
  final String? companyLogoUrl; // network logo (optional)
  final Color companyColor; // fallback avatar color when no logo

  // ── Technology stack tags (e.g. Flutter, Java, Angular, Node.js, React.js) ──
  final List<String> technologies;

  const JobPosting({
    required this.title,
    required this.applications,
    required this.distanceKm,
    required this.status,
    required this.companyName,
    required this.companyLocation,
    this.companyLogoUrl,
    this.companyColor = AppColors.primary,
    this.technologies = const [],
  });
}


// ─────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────
class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  JobStatus _selectedTab = JobStatus.active;

  // Dummy data — replace with your real data source / API call.
  final List<JobPosting> _jobs = const [
    JobPosting(
      title: 'Flutter Developer',
      applications: 48,
      distanceKm: 2.4,
      status: JobStatus.active,
      companyName: 'Infosys',
      companyLocation: 'Sitabuldi, Nagpur',
      companyColor: AppColors.coral,
      technologies: ['Flutter', 'Dart', 'Firebase'],
    ),
    JobPosting(
      title: 'Angular Developer',
      applications: 29,
      distanceKm: 3.1,
      status: JobStatus.active,
      companyName: 'TCS',
      companyLocation: 'Dharampeth, Nagpur',
      companyColor: AppColors.mint,
      technologies: ['Angular', 'TypeScript', 'RxJS'],
    ),
    JobPosting(
      title: 'React.js Developer',
      applications: 18,
      distanceKm: 5.2,
      status: JobStatus.active,
      companyName: 'Wipro',
      companyLocation: 'Civil Lines, Nagpur',
      companyColor: AppColors.pink,
      technologies: ['React.js', 'JavaScript', 'Redux'],
    ),
    JobPosting(
      title: 'Java Backend Developer',
      applications: 30,
      distanceKm: 1.8,
      status: JobStatus.paused,
      companyName: 'Accenture',
      companyLocation: 'Wardha Road, Nagpur',
      companyColor: AppColors.lime,
      technologies: ['Java', 'Spring Boot', 'MySQL'],
    ),
    JobPosting(
      title: 'Node.js Developer',
      applications: 12,
      distanceKm: 6.7,
      status: JobStatus.expired,
      companyName: 'Cognizant',
      companyLocation: 'Manish Nagar, Nagpur',
      companyColor: AppColors.primary,
      technologies: ['Node.js', 'Express', 'MongoDB'],
    ),
    JobPosting(
      title: 'Full Stack Developer',
      applications: 22,
      distanceKm: 4.3,
      status: JobStatus.draft,
      companyName: 'Tech Mahindra',
      companyLocation: 'Ramdaspeth, Nagpur',
      companyColor: AppColors.mint,
      technologies: ['React.js', 'Node.js', 'MongoDB'],
    ),
  ];

  int _countFor(JobStatus status) =>
      _jobs.where((j) => j.status == status).length;

  List<JobPosting> get _filteredJobs =>
      _jobs.where((j) => j.status == _selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildTabsRow(),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredJobs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: _filteredJobs.length,
                      itemBuilder: (context, index) {
                        return _JobCard(
                          job: _filteredJobs[index],
                          onTap: () {
                            // Card var click kel ki Post New Job page open hoto.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmployeePostNewJobPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomDock(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmployeePostNewJobPage(),
              ),
            );
          },
          backgroundColor: AppColors.buttonPrimary,
          elevation: 2,
          icon: const Icon(Icons.add, color: AppColors.buttonText),
          label: const Text(
            'Post New Job',
            style: TextStyle(
              color: AppColors.buttonText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
      ),
      title: const Text(
        "Categories",
        style: TextStyle(
          color: AppColors.buttonText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Tabs (Active / Draft / Expired / Paused) ─
  Widget _buildTabsRow() {
    final tabs = <JobStatus, String>{
      JobStatus.active: 'Active',
      JobStatus.draft: 'Draft',
      JobStatus.expired: 'Expired',
      JobStatus.paused: 'Paused',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.entries.map((entry) {
          final status = entry.key;
          final label = entry.value;
          final count = _countFor(status);
          final isSelected = status == _selectedTab;

          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = status),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$label ($count)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    width: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Empty state ─────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_outline_rounded,
              size: 56, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'No jobs in this category',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom dock (same style as Dashboard's dock) ──
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
                // Already on Jobs page
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
    final bool isActive = index == 2; // Jobs is index 2 and active on this page
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

// ─────────────────────────────────────────────
// JOB CARD
// ─────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final JobPosting job;
  final VoidCallback? onTap;

  const _JobCard({required this.job, this.onTap});

  // Status → (label, text color, background color)
  ({String label, Color fg, Color bg}) get _statusStyle {
    switch (job.status) {
      case JobStatus.active:
        return (
          label: 'Active',
          fg: AppColors.success,
          bg: AppColors.mintSoft,
        );
      case JobStatus.paused:
        return (
          label: 'Paused',
          fg: AppColors.error,
          bg: AppColors.pinkSoft,
        );
      case JobStatus.expired:
        return (
          label: 'Expired',
          fg: AppColors.textSecondary,
          bg: AppColors.divider,
        );
      case JobStatus.draft:
        return (
          label: 'Draft',
          fg: AppColors.warning,
          bg: AppColors.coralSoft,
        );
    }
  }

  String get _companyInitial =>
      job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company logo + name + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company logo (network image if provided, else initials avatar)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: job.companyLogoUrl != null
                      ? Image.network(
                          job.companyLogoUrl!,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _initialsAvatar(),
                        )
                      : _initialsAvatar(),
                ),
                const SizedBox(width: 12),

                // Company name + job title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.companyName,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: status.fg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Applications count
            Text(
              '${job.applications} Applications',
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            // ── Technology tags (Flutter, Java, Angular, Node.js, React.js etc.) ──
            if (job.technologies.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.technologies.map((tech) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tech,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 8),

            // Company location + distance + status row
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 15, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${job.companyLocation} • ${job.distanceKm} km away',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle, size: 8, color: status.fg),
                const SizedBox(width: 4),
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: status.fg,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialsAvatar() {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: job.companyColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _companyInitial,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: job.companyColor,
        ),
      ),
    );
  }
}