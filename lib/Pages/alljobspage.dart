import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_local_employee/Pages/employeecomapanyprofilepage.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationpage.dart';
import 'package:hyper_local_employee/Pages/employeepostnewjobpage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'package:hyper_local_employee/utils/company_profile_gate.dart';
import '../models/job_post_model.dart';
import '../controllers/job_post_controller.dart';

// ─────────────────────────────────────────────
// ENUM
// ─────────────────────────────────────────────
enum JobStatusTab { all, active, draft, expired, paused }

// ─────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────
class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  final JobPostController _controller = JobPostController();
  JobStatusTab _selectedTab = JobStatusTab.all;
  bool _isLoading = true;
  String? _errorMessage;
  List<JobPostModel> _jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _controller.fetchMyJobPosts();
      if (!mounted) return;
      setState(() {
        _jobs = _controller.myJobPosts;
        _errorMessage = _controller.errorMessage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  bool _matchesStatus(JobPostModel job, JobStatusTab tab) {
    if (tab == JobStatusTab.all) return true;
    final status = job.status.toLowerCase().trim();
    switch (tab) {
      case JobStatusTab.all:
        return true;
      case JobStatusTab.active:
        return status == 'active' || status == 'published' || status.isEmpty;
      case JobStatusTab.draft:
        return status == 'draft';
      case JobStatusTab.expired:
        return status == 'expired';
      case JobStatusTab.paused:
        return status == 'paused';
    }
  }

  int _countFor(JobStatusTab tab) {
    if (tab == JobStatusTab.all) return _jobs.length;
    return _jobs.where((j) => _matchesStatus(j, tab)).length;
  }

  List<JobPostModel> get _filteredJobs =>
      _jobs.where((j) => _matchesStatus(j, _selectedTab)).toList();

  Future<void> _publishJob(JobPostModel job) async {
    if (job.id == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Publishing job...'),
        duration: Duration(seconds: 1),
      ),
    );

    final ok = await _controller.publishJobPost(job.id!);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job "${job.jobTitle}" published successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      _fetchJobs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Failed to publish job'),
          backgroundColor: AppColors.coral,
        ),
      );
    }
  }

  Future<void> _confirmDeleteJob(JobPostModel job) async {
    if (job.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text('Delete Job Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${job.jobTitle ?? "this job"}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await _controller.deleteJobPost(job.id!);
      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job post deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _fetchJobs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage ?? 'Failed to delete job'),
            backgroundColor: AppColors.coral,
          ),
        );
      }
    }
  }

  Future<void> _editJob(JobPostModel job) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeePostNewJobPage(jobToEdit: job),
      ),
    );

    if (updated == true) {
      _fetchJobs();
    }
  }

  void _showJobDetails(JobPostModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle ?? 'Job Details',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (job.companyName != null && job.companyName!.isNotEmpty)
                          Text(
                            job.companyName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Details list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _detailRow('Category', job.jobCategory ?? '-'),
                  _detailRow('Role', job.jobRole ?? '-'),
                  _detailRow('Department', job.department ?? '-'),
                  _detailRow('Vacancies', '${job.numberOfVacancies ?? 1} (Remaining: ${job.remainingVacancies ?? job.numberOfVacancies ?? 1})'),
                  _detailRow('Employment Type', job.employmentType ?? '-'),
                  _detailRow('Job Level', job.jobLevel ?? '-'),
                  _detailRow('Experience Required', job.experienceRequired ?? '-'),
                  _detailRow('Qualification', job.qualification ?? '-'),
                  if (job.minSalary != null || job.maxSalary != null)
                    _detailRow('Salary', '₹${job.minSalary ?? 0} - ₹${job.maxSalary ?? 0} (${job.salaryFrequency ?? "Monthly"})'),
                  _detailRow('Shift Type', job.shiftType ?? '-'),
                  if (job.startTime != null && job.endTime != null)
                    _detailRow('Timings', '${job.startTime} to ${job.endTime}'),
                  if (job.workingDays.isNotEmpty)
                    _detailRow('Working Days', job.workingDays.join(', ')),
                  _detailRow('Weekly Off', job.weeklyOff ?? '-'),
                  _detailRow('Location', job.location ?? job.city ?? '-'),
                  if (job.stateId != null || job.cityId != null)
                    _detailRow('State / City ID', 'State ID: ${job.stateId ?? "-"}, City ID: ${job.cityId ?? "-"}'),
                  if (job.fullAddress != null && job.fullAddress!.isNotEmpty)
                    _detailRow('Full Address', job.fullAddress!),
                  if (job.skills.isNotEmpty)
                    _detailRow('Skills', job.skills.join(', ')),
                  if (job.languageRequirements.isNotEmpty)
                    _detailRow('Languages', job.languageRequirements.join(', ')),
                  if (job.jobSummary != null && job.jobSummary!.isNotEmpty)
                    _detailRow('Summary', job.jobSummary!),
                  if (job.responsibilities != null && job.responsibilities!.isNotEmpty)
                    _detailRow('Responsibilities', job.responsibilities!),
                  if (job.benefits != null && job.benefits!.isNotEmpty)
                    _detailRow('Benefits', job.benefits!),
                  _detailRow('Status', job.status.toUpperCase()),
                ],
              ),
            ),
            // Bottom buttons
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    if (job.status.toLowerCase() == 'draft') ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.rocket_launch, size: 18, color: AppColors.success),
                          label: const Text('Publish', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.success),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _publishJob(job);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.buttonText),
                        label: const Text('Edit Job', style: TextStyle(color: AppColors.buttonText, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _editJob(job);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDeleteJob(job);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _fetchJobs,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomDock(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 10),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final canProceed =
                await CompanyProfileGate.ensureProfileComplete(context);
            if (!canProceed || !context.mounted) return;

            final created = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmployeePostNewJobPage(),
              ),
            );
            if (created == true) {
              _fetchJobs();
            }
          },
          backgroundColor: AppColors.buttonPrimary,
          elevation: 3,
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null && _jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchJobs,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredJobs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return _JobCard(
          job: job,
          colorIndex: index,
          onTap: () => _showJobDetails(job),
          onEdit: () => _editJob(job),
          onDelete: () => _confirmDeleteJob(job),
          onPublish: () => _publishJob(job),
        );
      },
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
        "Manage Jobs",
        style: TextStyle(
          color: AppColors.buttonText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.buttonText),
          onPressed: _fetchJobs,
          tooltip: 'Refresh Jobs',
        ),
      ],
    );
  }

  // ── Tabs (All / Active / Draft / Expired / Paused) ─
  Widget _buildTabsRow() {
    final tabs = <JobStatusTab, String>{
      JobStatusTab.all: 'All',
      JobStatusTab.active: 'Active',
      JobStatusTab.draft: 'Draft',
      JobStatusTab.expired: 'Expired',
      JobStatusTab.paused: 'Paused',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.entries.map((entry) {
          final tab = entry.key;
          final label = entry.value;
          final count = _countFor(tab);
          final isSelected = tab == _selectedTab;

          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$label ($count)',
                    style: TextStyle(
                      fontSize: 14,
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
                    width: isSelected ? 36 : 0,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
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
    final bool hasAnyJobs = _jobs.isNotEmpty;
    final tabName = _selectedTab == JobStatusTab.all
        ? ''
        : _selectedTab == JobStatusTab.active
            ? 'active'
            : _selectedTab == JobStatusTab.draft
                ? 'draft'
                : _selectedTab == JobStatusTab.expired
                    ? 'expired'
                    : 'paused';

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline_rounded,
                  size: 56, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text(
                hasAnyJobs
                    ? 'No $tabName jobs found'
                    : 'No jobs posted yet',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasAnyJobs
                    ? 'Switch to another tab or post a new job'
                    : 'Tap "+ Post New Job" below to create your first listing',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom dock ──
  Widget _buildBottomDock() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeHomePage()),
                );
              }),
              _buildDockItem(Icons.dashboard_rounded, "Dashboard", 1, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeDashboardPage()),
                );
              }),
              _buildDockItem(Icons.work_rounded, "Jobs", 2, onTap: () {
                // Already on Jobs page
              }),
              _buildDockItem(Icons.description_rounded, "Applications", 3, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeApplicationPage()),
                );
              }),
              _buildDockItem(Icons.person_rounded, "Profile", 4, onTap: () {
                Navigator.pushReplacement(
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
    final bool isActive = index == 2;
    final Color color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
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
  final JobPostModel job;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPublish;

  const _JobCard({
    required this.job,
    required this.colorIndex,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onPublish,
  });

  ({String label, Color fg, Color bg}) get _statusStyle {
    final s = job.status.toLowerCase().trim();
    if (s == 'active' || s == 'published') {
      return (label: 'Active', fg: AppColors.success, bg: AppColors.mintSoft);
    } else if (s == 'draft') {
      return (label: 'Draft', fg: AppColors.warning, bg: AppColors.coralSoft);
    } else if (s == 'paused') {
      return (label: 'Paused', fg: AppColors.error, bg: AppColors.pinkSoft);
    } else if (s == 'expired') {
      return (label: 'Expired', fg: AppColors.textSecondary, bg: AppColors.divider);
    }
    return (label: s.isEmpty ? 'Active' : s, fg: AppColors.primary, bg: AppColors.accentsSoft[0]);
  }

  Color get _avatarColor {
    return AppColors.accents[colorIndex % AppColors.accents.length];
  }

  String get _initial {
    if (job.companyInitial != null && job.companyInitial!.trim().isNotEmpty) {
      return job.companyInitial!.trim().toUpperCase();
    }
    if (job.companyName != null && job.companyName!.trim().isNotEmpty) {
      return job.companyName!.trim()[0].toUpperCase();
    }
    if (job.jobTitle != null && job.jobTitle!.trim().isNotEmpty) {
      return job.jobTitle!.trim()[0].toUpperCase();
    }
    return 'J';
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle;
    final isDraft = job.status.toLowerCase().trim() == 'draft';

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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Initial avatar + Company & Title + Action Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _avatarColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _initial,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _avatarColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Company Name + Job Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (job.companyName != null && job.companyName!.isNotEmpty)
                            ? job.companyName!
                            : (job.jobCategory ?? 'Job Post'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.jobTitle ?? 'Untitled Job',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Menu (Edit, Publish, Delete)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'publish') onPublish();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          SizedBox(width: 10),
                          Text('Edit', style: TextStyle(fontSize: 13.5)),
                        ],
                      ),
                    ),
                    if (isDraft)
                      const PopupMenuItem(
                        value: 'publish',
                        child: Row(
                          children: [
                            Icon(Icons.rocket_launch_outlined, size: 18, color: AppColors.success),
                            SizedBox(width: 10),
                            Text('Publish', style: TextStyle(fontSize: 13.5, color: AppColors.success)),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(fontSize: 13.5, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Salary & Vacancies / Status row
            Row(
              children: [
                if (job.hideSalary)
                  const Text(
                    'Salary hidden',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  )
                else if (job.minSalary != null || job.maxSalary != null)
                  Text(
                    '₹${job.minSalary ?? 0} - ₹${job.maxSalary ?? 0} • ${job.salaryFrequency ?? "Monthly"}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    '${job.numberOfVacancies ?? 1} Vacancies',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const Spacer(),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: status.fg,
                    ),
                  ),
                ),
                if (isDraft) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onPublish,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rocket_launch, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Publish',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Skills chips (if any)
            if (job.skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.skills.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      skill,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList()
                  ..addAll([
                    if (job.skills.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${job.skills.length - 3}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                  ]),
              ),
            ],

            const SizedBox(height: 10),

            // Location + distance row
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location ?? (job.city != null && job.city!.isNotEmpty ? job.city! : 'India'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                if (job.distanceKm != null && job.distanceKm! > 0) ...[
                  Text(
                    '${job.distanceKm} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
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
}
