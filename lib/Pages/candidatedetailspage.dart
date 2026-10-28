import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hyper_local_employee/models/candidate_card_model.dart';
import 'package:hyper_local_employee/Pages/employeeinterviewschedulepage.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/services/user_session.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CandidateDetailsPage extends StatefulWidget {
  final int applicationId;
  final CandidateCardModel? initialCandidate;

  const CandidateDetailsPage({
    super.key,
    required this.applicationId,
    this.initialCandidate,
  });

  @override
  State<CandidateDetailsPage> createState() => _CandidateDetailsPageState();
}

class _CandidateDetailsPageState extends State<CandidateDetailsPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _interviewData;
  bool _isShortlisting = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getCandidateDetails(widget.applicationId);
      final interview = await ApiService.getInterviewByApplication(widget.applicationId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _interviewData = interview;
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


  Future<void> _shortlistCandidate() async {
    setState(() => _isShortlisting = true);
    try {
      await ApiService.updateApplicationStatus(widget.applicationId, 'shortlisted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Candidate shortlisted successfully!', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.success,
        ),
      );
      await _fetchDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''), style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isShortlisting = false);
    }
  }

  String _val(dynamic value, [String fallback = 'Not available']) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return fallback;
    return str;
  }

  Future<void> _openResume(String? resumeFile) async {
    final cleanResume = (resumeFile ?? '').trim();
    if (cleanResume.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resume not available', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String urlStr;
    if (cleanResume.startsWith('http://') || cleanResume.startsWith('https://')) {
      urlStr = cleanResume;
    } else {
      final cleanBase = ApiService.baseUrl.endsWith('/')
          ? ApiService.baseUrl.substring(0, ApiService.baseUrl.length - 1)
          : ApiService.baseUrl;
      urlStr = '$cleanBase/job-applications/${widget.applicationId}/resume';
    }

    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open resume file', style: GoogleFonts.poppins()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening resume: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data ?? {};
    final init = widget.initialCandidate;
    final name = _val(d['name'] ?? init?.name, 'Applicant');
    final appliedFor = _val(d['applied_for'] ?? init?.appliedFor, 'Applied Position');
    final status = _val(d['application_status'] ?? init?.applicationStatus, 'Applied');
    final int? candidateId = (d['user_id'] is int)
        ? d['user_id'] as int
        : (int.tryParse(d['user_id']?.toString() ?? '') ?? init?.userId);
    final int? jobPostId = (d['job_post_id'] is int)
        ? d['job_post_id'] as int
        : (int.tryParse(d['job_post_id']?.toString() ?? '') ?? init?.jobPostId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Candidate Profiles',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryDeep,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
      bottomNavigationBar: (!_loading && _error == null)
          ? _buildBottomBar(name, appliedFor, candidateId, jobPostId, status)
          : null,
    );
  }

  Widget _buildBody() {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 54, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load details',
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
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    final d = _data ?? {};
    final init = widget.initialCandidate;

    final name = _val(d['name'] ?? init?.name, 'Applicant');
    final appliedFor = _val(d['applied_for'] ?? init?.appliedFor, 'Applied Position');
    final matchPercent = d['match_percentage'] ?? init?.matchPercentage ?? 85;
    final status = _val(d['application_status'] ?? init?.applicationStatus, 'Applied');
    final email = _val(d['email']);
    final mobile = _val(d['mobile_no']);
    final address = _val(d['address'] ?? init?.address);
    final city = _val(d['city']);
    final state = _val(d['state']);
    final pincode = _val(d['pincode']);
    final exp = _val(d['experience'] ?? init?.experienceText);
    final notice = _val(d['notice_period_days'] != null ? '${d['notice_period_days']} Days' : init?.noticeText);
    final empType = _val(d['employment_type'] ?? init?.employmentType);
    final ctc = _val(init?.ctcText != 'Not specified' ? init?.ctcText : null);
    final education = _val(d['education'] ?? init?.education);
    final resumeFile = d['resume_file'] ?? init?.resumeFile;
    final hasResume = d['has_resume'] == true || (init?.hasResume ?? false);

    List<String> skillsList = [];
    if (d['skills'] is List) {
      skillsList = (d['skills'] as List).map((e) => e.toString()).toList();
    } else if (init != null && init.skills.isNotEmpty) {
      skillsList = init.skills;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appliedFor,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Text(
                        'Status: ${status.toUpperCase()}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Match badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${(matchPercent is num ? matchPercent : 85).round()}% Match',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Scheduled Interview Card (Showing real backend Candidate Response Status: Pending / Accepted / Rejected)
          if (_interviewData != null) ...[
            _buildInterviewCard(_interviewData!),
            const SizedBox(height: 16),
          ],

          // Contact Information Card
          _buildSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_page_rounded,
            children: [
              _buildDetailRow(Icons.email_outlined, 'Email', email),
              _buildDetailRow(Icons.phone_outlined, 'Mobile', mobile),
              _buildDetailRow(Icons.location_on_outlined, 'Address', address),
              if (city != 'Not available') _buildDetailRow(Icons.location_city_outlined, 'City', city),
              if (state != 'Not available') _buildDetailRow(Icons.map_outlined, 'State', state),
              if (pincode != 'Not available') _buildDetailRow(Icons.pin_drop_outlined, 'Pincode', pincode),
            ],
          ),

          const SizedBox(height: 16),

          // Professional Information Card
          _buildSectionCard(
            title: 'Professional Information',
            icon: Icons.work_history_rounded,
            children: [
              _buildDetailRow(Icons.work_history_outlined, 'Experience', exp),
              _buildDetailRow(Icons.event_available_outlined, 'Notice Period', notice),
              _buildDetailRow(Icons.access_time_rounded, 'Employment Type', empType),
              _buildDetailRow(Icons.currency_rupee_rounded, 'Expected CTC', ctc),
              _buildDetailRow(Icons.work_outline_rounded, 'Applied Position', appliedFor),
            ],
          ),

          const SizedBox(height: 16),

          // Education Card
          _buildSectionCard(
            title: 'Education',
            icon: Icons.school_rounded,
            children: [
              _buildDetailRow(Icons.school_outlined, 'Qualification', education),
            ],
          ),

          const SizedBox(height: 16),

          // Skills Card
          _buildSectionCard(
            title: 'Skills',
            icon: Icons.code_rounded,
            children: [
              if (skillsList.isEmpty)
                Text(
                  'No skills specified',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skillsList.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lime.withOpacity(0.5)),
                      ),
                      child: Text(
                        skill,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Resume Card
          _buildSectionCard(
            title: 'Resume Document',
            icon: Icons.description_rounded,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasResume ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: hasResume ? AppColors.success : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasResume ? 'Resume Attached' : 'Resume Not Available',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (hasResume)
                    ElevatedButton.icon(
                      onPressed: () => _openResume(resumeFile),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: Text('Open Resume', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatInterviewDate(dynamic raw) {
    if (raw == null) return 'Not set';
    final str = raw.toString();
    try {
      final dt = DateTime.parse(str).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return str.split('T').first;
    }
  }

  Widget _buildInterviewCard(Map<String, dynamic> iv) {
    final mode = (iv['interview_mode'] ?? 'online').toString();
    final isOnline = mode.toLowerCase() == 'online';
    final dateStr = _formatInterviewDate(iv['interview_date']);
    final timeStr = iv['interview_time']?.toString() ?? 'Not specified';
    final interviewer = iv['interviewer_name']?.toString() ?? 'Not specified';
    final designation = iv['interviewer_designation']?.toString() ?? '';
    final meetingLink = (iv['interview_link']?.toString() ?? '').trim();
    final venue = (iv['interview_location']?.toString() ??
            iv['interview_venue']?.toString() ??
            'Office Venue')
        .trim();
    final responseStatus =
        (iv['response_status'] ?? 'pending').toString().toLowerCase();
    final candidateRemark = (iv['candidate_response_remark']?.toString() ?? '').trim();

    Color badgeColor;
    String badgeLabel;
    IconData badgeIcon;

    if (responseStatus == 'accepted') {
      badgeColor = AppColors.success;
      badgeLabel = 'Accepted';
      badgeIcon = Icons.check_circle_rounded;
    } else if (responseStatus == 'rejected') {
      badgeColor = AppColors.error;
      badgeLabel = 'Rejected';
      badgeIcon = Icons.cancel_rounded;
    } else {
      badgeColor = AppColors.warning;
      badgeLabel = 'Pending Response';
      badgeIcon = Icons.schedule_rounded;
    }

    return _buildSectionCard(
      title: 'Scheduled Interview',
      icon: Icons.calendar_month_rounded,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Candidate Response:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: badgeColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 14, color: badgeColor),
                  const SizedBox(width: 4),
                  Text(
                    badgeLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (candidateRemark.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Text(
              'Candidate Remark: "$candidateRemark"',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        _buildDetailRow(Icons.event_outlined, 'Date & Time', '$dateStr at $timeStr'),
        _buildDetailRow(
          isOnline ? Icons.videocam_outlined : Icons.business_outlined,
          'Interview Mode',
          isOnline ? 'Online (Video Call)' : 'Offline (In-Person)',
        ),
        if (isOnline && meetingLink.isNotEmpty)
          _buildDetailRow(Icons.link_rounded, 'Meeting Link', meetingLink),
        if (!isOnline && venue.isNotEmpty)
          _buildDetailRow(Icons.place_outlined, 'Venue / Address', venue),
        _buildDetailRow(
          Icons.person_outline_rounded,
          'Interviewer',
          designation.isNotEmpty ? '$interviewer ($designation)' : interviewer,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    String candidateName,
    String candidateRole,
    int? candidateId,
    int? jobPostId,
    String currentStatus,
  ) {
    final bool isShortlisted = currentStatus.toLowerCase() == 'shortlisted';
    final bool hasInterview = _interviewData != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isShortlisted && !hasInterview) ...[
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isShortlisting ? null : _shortlistCandidate,
                    icon: _isShortlisting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.star_rounded, size: 18, color: Colors.white),
                    label: Text(
                      'Shortlist',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeInterviewSchedulePage(
                            applicationId: widget.applicationId,
                            existingInterviewId: _interviewData != null
                                ? (int.tryParse(_interviewData!['id']?.toString() ?? '') ??
                                    int.tryParse(_interviewData!['interview_id']?.toString() ?? ''))
                                : null,
                            candidate: {
                              'name': candidateName,
                              'role': candidateRole,
                              'application_id': widget.applicationId,
                              'interview_id': _interviewData != null
                                  ? (_interviewData!['id'] ?? _interviewData!['interview_id'])
                                  : null,
                            },
                          ),
                        ),
                      ).then((val) {
                        if (val == true) _fetchDetails();
                      });
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white),
                    label: Text(
                      hasInterview ? 'Reschedule' : 'Schedule',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _openInvitationModal(
                    candidateId: candidateId,
                    jobPostId: jobPostId,
                    candidateName: candidateName,
                    appliedRole: candidateRole,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18, color: AppColors.primary),
                  label: Text(
                    'Send Invite',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInvitationModal({
    required int? candidateId,
    required int? jobPostId,
    required String candidateName,
    required String appliedRole,
  }) {
    if (candidateId == null || candidateId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Candidate ID not found for this profile.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _InterviewInvitationSheet(
          candidateId: candidateId,
          jobPostId: jobPostId,
          candidateName: candidateName,
          appliedRole: appliedRole,
          onInvitationSuccess: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        );
      },
    );
  }
}

class _InterviewInvitationSheet extends StatefulWidget {
  final int candidateId;
  final int? jobPostId;
  final String candidateName;
  final String appliedRole;
  final void Function(String message) onInvitationSuccess;

  const _InterviewInvitationSheet({
    required this.candidateId,
    required this.jobPostId,
    required this.candidateName,
    required this.appliedRole,
    required this.onInvitationSuccess,
  });

  @override
  State<_InterviewInvitationSheet> createState() => _InterviewInvitationSheetState();
}

class _InterviewInvitationSheetState extends State<_InterviewInvitationSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _jobIdController;
  late TextEditingController _messageController;
  late TextEditingController _linkController;
  late TextEditingController _locationController;
  late TextEditingController _instructionsController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMinutes = 30;
  String _mode = 'online'; // 'online' or 'offline'
  String _type = 'technical'; // 'technical', 'hr', 'managerial', 'other'

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _jobIdController = TextEditingController(
      text: widget.jobPostId != null ? widget.jobPostId.toString() : '',
    );
    _messageController = TextEditingController(
      text: 'We would like to invite you for an interview.',
    );
    _linkController = TextEditingController();
    _locationController = TextEditingController();
    _instructionsController = TextEditingController(
      text: 'Please join 5 minutes early.',
    );
  }

  @override
  void dispose() {
    _jobIdController.dispose();
    _messageController.dispose();
    _linkController.dispose();
    _locationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 15, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitInvitation() async {
    if (_submitting) return;

    setState(() => _errorMessage = null);

    final rawJobId = _jobIdController.text.trim();
    final jobId = int.tryParse(rawJobId);
    if (jobId == null || jobId <= 0) {
      setState(() => _errorMessage = 'Please enter a valid Job ID.');
      return;
    }

    if (_selectedDate != null && _selectedTime == null) {
      setState(() => _errorMessage = 'Interview time is required when date is selected.');
      return;
    }

    if (_selectedTime != null && _selectedDate == null) {
      setState(() => _errorMessage = 'Interview date is required when time is selected.');
      return;
    }

    if (_selectedDate != null) {
      if (_mode == 'online' && _linkController.text.trim().isEmpty) {
        setState(() => _errorMessage = 'Meeting link is required for online interviews.');
        return;
      }
      if (_mode == 'offline' && _locationController.text.trim().isEmpty) {
        setState(() => _errorMessage = 'Location is required for offline interviews.');
        return;
      }
    }

    // Employer ID from session/prefs
    final prefs = await SharedPreferences.getInstance();
    int? employerId = prefs.getInt('employer_id');
    if (employerId == null) {
      final raw = prefs.get('employer_id');
      if (raw != null) employerId = int.tryParse(raw.toString());
    }
    employerId ??= prefs.getInt('employee_id');
    if (employerId == null && UserSession.currentEmployee != null) {
      employerId = UserSession.currentEmployee!.id;
    }
    employerId ??= 1;

    setState(() => _submitting = true);

    String? formattedDate;
    if (_selectedDate != null) {
      formattedDate =
          '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    }

    String? formattedTime;
    if (_selectedTime != null) {
      formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
    }

    final payload = <String, dynamic>{
      'employer_id': employerId,
      'candidate_id': widget.candidateId,
      'job_post_id': jobId,
      if (_messageController.text.trim().isNotEmpty)
        'message': _messageController.text.trim(),
      'interview_date': ?formattedDate,
      'interview_time': ?formattedTime,
      if (_selectedDate != null)
        'interview_duration_minutes': _durationMinutes,
      if (_selectedDate != null) 'interview_mode': _mode.toLowerCase(),
      if (_selectedDate != null) 'interview_type': _type.toLowerCase(),
      if (_mode == 'online' && _linkController.text.trim().isNotEmpty)
        'interview_link': _linkController.text.trim(),
      if (_mode == 'offline' && _locationController.text.trim().isNotEmpty)
        'interview_location': _locationController.text.trim(),
      if (_instructionsController.text.trim().isNotEmpty)
        'interview_instructions': _instructionsController.text.trim(),
    };

    try {
      final res = await ApiService.sendCandidateInvitation(payload);
      if (!mounted) return;
      setState(() => _submitting = false);
      Navigator.pop(context);
      final msg = res['message']?.toString() ?? 'Invitation sent successfully!';
      widget.onInvitationSuccess(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Interview Invitation',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Candidate: ${widget.candidateName} (ID: ${widget.candidateId})',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  color: AppColors.error,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Job Post ID
                    _fieldLabel('Job ID (Required)'),
                    TextFormField(
                      controller: _jobIdController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hintText: 'Enter Job ID',
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Invitation Message
                    _fieldLabel('Invitation Message (Optional)'),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        hintText: 'Message to candidate',
                        prefixIcon: Icons.message_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Interview Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Interview Date'),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 13),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded,
                                          size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedDate != null
                                              ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                                              : 'Select Date',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: _selectedDate != null
                                                ? AppColors.textPrimary
                                                : AppColors.textHint,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Interview Time'),
                              InkWell(
                                onTap: _pickTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 13),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded,
                                          size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedTime != null
                                              ? _selectedTime!.format(context)
                                              : 'Select Time',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: _selectedTime != null
                                                ? AppColors.textPrimary
                                                : AppColors.textHint,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Duration & Type
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Duration (Minutes)'),
                              DropdownButtonFormField<int>(
                                initialValue: _durationMinutes,
                                decoration: _inputDecoration(
                                  prefixIcon: Icons.timer_outlined,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 15, child: Text('15 Mins')),
                                  DropdownMenuItem(value: 30, child: Text('30 Mins')),
                                  DropdownMenuItem(value: 45, child: Text('45 Mins')),
                                  DropdownMenuItem(value: 60, child: Text('60 Mins')),
                                  DropdownMenuItem(value: 90, child: Text('90 Mins')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _durationMinutes = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Interview Type'),
                              DropdownButtonFormField<String>(
                                initialValue: _type,
                                decoration: _inputDecoration(
                                  prefixIcon: Icons.category_outlined,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'technical', child: Text('Technical')),
                                  DropdownMenuItem(value: 'hr', child: Text('HR')),
                                  DropdownMenuItem(value: 'managerial', child: Text('Managerial')),
                                  DropdownMenuItem(value: 'other', child: Text('Other')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _type = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Mode Selection
                    _fieldLabel('Interview Mode'),
                    Row(
                      children: [
                        Expanded(
                          child: _modeOptionCard(
                            label: 'Online',
                            icon: Icons.videocam_rounded,
                            isSelected: _mode == 'online',
                            onTap: () => setState(() => _mode = 'online'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _modeOptionCard(
                            label: 'Offline',
                            icon: Icons.location_on_rounded,
                            isSelected: _mode == 'offline',
                            onTap: () => setState(() => _mode = 'offline'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Link or Location
                    if (_mode == 'online') ...[
                      _fieldLabel('Meeting Link (Required for Online)'),
                      TextFormField(
                        controller: _linkController,
                        decoration: _inputDecoration(
                          hintText: 'e.g. https://meet.google.com/xyz',
                          prefixIcon: Icons.link_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      _fieldLabel('Interview Location (Required for Offline)'),
                      TextFormField(
                        controller: _locationController,
                        maxLines: 2,
                        decoration: _inputDecoration(
                          hintText: 'e.g. Office Suite 201, MG Road',
                          prefixIcon: Icons.place_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Instructions
                    _fieldLabel('Interview Instructions (Optional)'),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        hintText: 'e.g. Please join 5 mins early with portfolio',
                        prefixIcon: Icons.info_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submitInvitation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Submit Invitation',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textHint),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: AppColors.primary)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _modeOptionCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
