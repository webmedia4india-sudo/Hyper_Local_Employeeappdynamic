import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/services/user_session.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeInterviewSchedulePage extends StatefulWidget {
  final int? applicationId;
  final Map<String, dynamic>? candidate;
  final int? existingInterviewId;

  const EmployeeInterviewSchedulePage({
    super.key,
    this.applicationId,
    this.candidate,
    this.existingInterviewId,
  });

  @override
  State<EmployeeInterviewSchedulePage> createState() =>
      _EmployeeInterviewSchedulePageState();
}

class _EmployeeInterviewSchedulePageState
    extends State<EmployeeInterviewSchedulePage> {
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 11, minute: 0);
  String _interviewType = 'In-Person';

  int? _selectedApplicationId;
  Map<String, dynamic>? _selectedCandidate;
  List<Map<String, dynamic>> _availableApplications = [];
  bool _loadingApplications = false;

  final List<String> _interviewTypes = const [
    'In-Person',
    'Video Call',
    'Phone Call',
  ];

  late final TextEditingController _meetingLinkController;
  late final TextEditingController _venueController;
  late final TextEditingController _interviewerNameController;
  late final TextEditingController _interviewerDesignationController;
  late final TextEditingController _remarkController;

  final List<String> _panelMembers = [];
  bool _isSubmitting = false;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = tomorrow;

    _selectedApplicationId = widget.applicationId;
    if (_selectedApplicationId == null && widget.candidate != null) {
      final raw = widget.candidate!['application_id'] ??
          widget.candidate!['id'] ??
          widget.candidate!['applicationId'];
      if (raw != null) _selectedApplicationId = int.tryParse(raw.toString());
    }
    _selectedCandidate = widget.candidate;

    if (_selectedApplicationId == null) {
      _loadEmployerApplications();
    }

    final initialName = UserSession.userName.isNotEmpty
        ? UserSession.userName
        : 'Gauri Chaure';
    final initialCompany = UserSession.companyName.isNotEmpty
        ? UserSession.companyName
        : 'Amravati Branch Office';

    _panelMembers.add('$initialName (You)');

    _meetingLinkController = TextEditingController();
    _venueController = TextEditingController(text: initialCompany);
    _interviewerNameController = TextEditingController(text: initialName);
    _interviewerDesignationController =
        TextEditingController(text: 'Sales');
    _remarkController = TextEditingController(
      text: 'Please join 5 minutes before scheduled time with relevant documents.',
    );
  }

  Future<void> _loadEmployerApplications() async {
    setState(() => _loadingApplications = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      int? employerId = prefs.getInt('employer_id');
      if (employerId == null) {
        final raw = prefs.get('employer_id');
        if (raw != null) employerId = int.tryParse(raw.toString());
      }
      if (employerId == null) {
        employerId = prefs.getInt('employee_id');
        if (employerId == null) {
          final raw = prefs.get('employee_id');
          if (raw != null) employerId = int.tryParse(raw.toString());
        }
      }
      employerId ??= UserSession.currentEmployee?.companyId;
      employerId ??= UserSession.currentEmployee?.id;
      employerId ??= 2;

      var apps = await ApiService.getEmployerApplications(employerId);
      if (apps.isEmpty) {
        final altId = (employerId == 1) ? 2 : 1;
        final altApps = await ApiService.getEmployerApplications(altId);
        if (altApps.isNotEmpty) {
          apps = altApps;
          employerId = altId;
        }
      }

      if (!mounted) return;
      setState(() {
        _availableApplications = apps;
        _loadingApplications = false;
        if (_selectedApplicationId == null && apps.isNotEmpty) {
          final shortlisted = apps.firstWhere(
            (a) => (a['application_status'] ?? '').toString().toLowerCase() == 'shortlisted',
            orElse: () => apps.first,
          );
          final rawId = shortlisted['application_id'] ?? shortlisted['id'];
          if (rawId != null) {
            _selectedApplicationId = int.tryParse(rawId.toString());
            _selectedCandidate = shortlisted;
          }
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingApplications = false);
    }
  }

  void _pickCandidate() async {
    if (_availableApplications.isEmpty) {
      await _loadEmployerApplications();
      if (!mounted) return;
      if (_availableApplications.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No candidate applications found to schedule.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Candidate to Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableApplications.length,
                  itemBuilder: (context, i) {
                    final app = _availableApplications[i];
                    final candName = (app['name'] ?? app['candidate_name'] ?? app['user_name'] ?? 'Candidate').toString();
                    final role = (app['job_title'] ?? app['role'] ?? app['applied_for'] ?? 'Applicant').toString();
                    final rawId = app['application_id'] ?? app['id'];
                    final appId = int.tryParse(rawId?.toString() ?? '');
                    final isSel = appId == _selectedApplicationId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          candName.isNotEmpty ? candName[0].toUpperCase() : 'C',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(candName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(role, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: isSel ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                      onTap: () {
                        setState(() {
                          _selectedApplicationId = appId;
                          _selectedCandidate = app;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _meetingLinkController.dispose();
    _venueController.dispose();
    _interviewerNameController.dispose();
    _interviewerDesignationController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}';

  String get _formattedDateYMD {
    final y = _selectedDate.year.toString().padLeft(4, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final d = _selectedDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String get _formattedTime24 {
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get _formattedTime {
    final hour =
        _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _pickInterviewType() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _interviewTypes.map((type) {
              final bool isSelected = type == _interviewType;
              return ListTile(
                title: Text(
                  type,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _interviewType = type);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _addMember() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Add Panel Member',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter member name',
              hintStyle:
                  const TextStyle(color: AppColors.textHint, fontSize: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() => _panelMembers.add(controller.text.trim()));
                }
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ── SUBMIT SCHEDULE INTERVIEW ──
  Future<void> _submitSchedule() async {
    int? appId = _selectedApplicationId ?? widget.applicationId;
    if (appId == null && _selectedCandidate != null) {
      final raw = _selectedCandidate!['application_id'] ??
          _selectedCandidate!['id'] ??
          _selectedCandidate!['applicationId'];
      if (raw != null) appId = int.tryParse(raw.toString());
    } else if (appId == null && widget.candidate != null) {
      final raw = widget.candidate!['application_id'] ??
          widget.candidate!['id'] ??
          widget.candidate!['applicationId'];
      if (raw != null) appId = int.tryParse(raw.toString());
    }

    // Auto-pick first application if available
    if ((appId == null || appId <= 0) && _availableApplications.isNotEmpty) {
      final firstApp = _availableApplications.first;
      final raw = firstApp['application_id'] ?? firstApp['id'];
      if (raw != null) {
        appId = int.tryParse(raw.toString());
        _selectedApplicationId = appId;
        _selectedCandidate = firstApp;
      }
    }

    if (appId == null || appId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid candidate application first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String mode = 'offline';
    if (_interviewType == 'Video Call') {
      mode = 'online';
    } else if (_interviewType == 'Phone Call') {
      mode = 'phone';
    }

    // Online meeting link validation
    if (mode == 'online') {
      final link = _meetingLinkController.text.trim();
      if (link.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid meeting link (Zoom / Google Meet URL)'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      final uri = Uri.tryParse(link);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting link must start with http:// or https://'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // Offline venue validation
    if (mode == 'offline') {
      final venue = _venueController.text.trim();
      if (venue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the interview venue / office address'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'interviewDate': _formattedDateYMD,
      'interviewTime': _formattedTime24,
      'interviewMode': mode,
      'interviewerName': _interviewerNameController.text.trim().isNotEmpty
          ? _interviewerNameController.text.trim()
          : (UserSession.userName.isNotEmpty ? UserSession.userName : 'Gauri Chaure'),
      'interviewerDesignation': _interviewerDesignationController.text.trim().isNotEmpty
          ? _interviewerDesignationController.text.trim()
          : 'Sales',
      'meetingLink': mode == 'online' ? _meetingLinkController.text.trim() : '',
      'venue': mode == 'offline' ? _venueController.text.trim() : '',
      'remark': _remarkController.text.trim(),
    };

    try {
      // Ensure application is marked shortlisted
      try {
        await ApiService.updateApplicationStatus(appId, 'shortlisted');
      } catch (_) {}

      int? existingId = widget.existingInterviewId;
      if (existingId == null && widget.candidate != null) {
        final rawId = widget.candidate!['interview_id'] ?? widget.candidate!['interviewId'];
        if (rawId != null) existingId = int.tryParse(rawId.toString());
      }

      if (existingId != null && existingId > 0) {
        await ApiService.rescheduleInterview(existingId, payload);
      } else {
        await ApiService.scheduleInterview(appId, payload);
      }
      if (!mounted) return;
      _showCongratsDialog();
    } catch (e) {
      final err = e.toString().replaceAll('Exception: ', '');
      if (err.toLowerCase().contains('already exists')) {
        try {
          final existing = await ApiService.getInterviewByApplication(appId);
          final existingId = existing != null
              ? (existing['id'] as int? ?? existing['interview_id'] as int?)
              : null;
          if (existingId != null && existingId > 0) {
            await ApiService.rescheduleInterview(existingId, payload);
            if (!mounted) return;
            _showCongratsDialog();
            return;
          }
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── ANIMATED CONGRATS DIALOG ──
  void _showCongratsDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Congrats",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => _CongratsDialogContent(
        onDone: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context, true); // return true to refresh caller
        },
      ),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: curved.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = _selectedCandidate?['name'] as String? ??
        _selectedCandidate?['candidate_name'] as String? ??
        _selectedCandidate?['user_name'] ??
        widget.candidate?['name'] as String? ??
        widget.candidate?['candidate_name'] as String? ??
        widget.candidate?['user_name'] ??
        (_loadingApplications
            ? 'Loading candidate...'
            : (_availableApplications.isNotEmpty
                ? (_availableApplications.first['name'] ??
                    _availableApplications.first['candidate_name'] ??
                    _availableApplications.first['user_name'] ??
                    'Candidate')
                : 'Select Candidate'));
    final String role = _selectedCandidate?['role'] as String? ??
        _selectedCandidate?['job_title'] ??
        widget.candidate?['role'] as String? ??
        widget.candidate?['job_title'] ??
        (_availableApplications.isNotEmpty
            ? (_availableApplications.first['job_title'] ??
                _availableApplications.first['role'] ??
                'Applicant')
            : 'Tap to choose candidate');

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
          "Schedule Interviews",
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Candidate"),
                  const SizedBox(height: 6),
                  _buildCandidateCard(name, role),
                  const SizedBox(height: 14),

                  _sectionLabel("Date"),
                  const SizedBox(height: 5),
                  _buildPickerField(
                    value: _formattedDate,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 10),

                  _sectionLabel("Time"),
                  const SizedBox(height: 5),
                  _buildPickerField(
                    value: _formattedTime,
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 10),

                  _sectionLabel("Interview Type"),
                  const SizedBox(height: 5),
                  _buildPickerField(
                    value: _interviewType,
                    onTap: _pickInterviewType,
                  ),
                  const SizedBox(height: 14),

                  // ── ONLINE / OFFLINE CONDITIONAL FIELDS (STEP 4) ──
                  if (_interviewType == 'Video Call') ...[
                    _sectionLabel("Meeting Link (Zoom / Google Meet URL)"),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.border.withOpacity(0.8), width: 1),
                      ),
                      child: TextField(
                        controller: _meetingLinkController,
                        decoration: const InputDecoration(
                          hintText: 'https://zoom.us/j/... or meeting URL',
                          hintStyle: TextStyle(
                              color: AppColors.textHint, fontSize: 13),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.link_rounded,
                              color: AppColors.primary, size: 20),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 32, minHeight: 0),
                        ),
                        style: const TextStyle(
                            fontSize: 13.5, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ] else if (_interviewType == 'In-Person') ...[
                    _sectionLabel("Physical Interview Venue / Office Address"),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.border.withOpacity(0.8), width: 1),
                      ),
                      child: TextField(
                        controller: _venueController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Amravati Branch Office, 2nd Floor',
                          hintStyle: TextStyle(
                              color: AppColors.textHint, fontSize: 13),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.place_rounded,
                              color: AppColors.primary, size: 20),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 32, minHeight: 0),
                        ),
                        style: const TextStyle(
                            fontSize: 13.5, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  _sectionLabel("Interviewer Name"),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.border.withOpacity(0.8), width: 1),
                    ),
                    child: TextField(
                      controller: _interviewerNameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Gauri Chaure',
                        hintStyle: TextStyle(
                            color: AppColors.textHint, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _sectionLabel("Interviewer Designation"),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.border.withOpacity(0.8), width: 1),
                    ),
                    child: TextField(
                      controller: _interviewerDesignationController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Sales / HR',
                        hintStyle: TextStyle(
                            color: AppColors.textHint, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _sectionLabel("Instructions / Remark"),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.border.withOpacity(0.8), width: 1),
                    ),
                    child: TextField(
                      controller: _remarkController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Please join 5 minutes before scheduled time.',
                        hintStyle: TextStyle(
                            color: AppColors.textHint, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _sectionLabel("Add Panel Members"),
                  const SizedBox(height: 5),
                  _buildPanelMembers(),
                ],
              ),
            ),
          ),
          _buildSendInviteButton(),
        ],
      ),
    );
  }

  // ── SECTION LABEL ──
  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ── CANDIDATE CARD ──
  Widget _buildCandidateCard(String name, String role) {
    final bool canChange = widget.applicationId == null;

    return GestureDetector(
      onTap: canChange ? _pickCandidate : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (canChange)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Select', style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── DATE / TIME / TYPE PICKER FIELD ──
  Widget _buildPickerField({
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.border.withOpacity(0.8), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.unfold_more_rounded,
                size: 19, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ── PANEL MEMBERS ──
  Widget _buildPanelMembers() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._panelMembers.map((member) => _buildMemberChip(member)),
        GestureDetector(
          onTap: _addMember,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_circle_outline_rounded,
                  size: 17, color: AppColors.primary),
              SizedBox(width: 5),
              Text(
                "Add Member",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberChip(String member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.8), width: 1),
      ),
      child: Text(
        member,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── SEND INVITE BUTTON ──
  Widget _buildSendInviteButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Send Invite',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.buttonText,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── ANIMATED CONGRATS DIALOG CONTENT ──
class _CongratsDialogContent extends StatefulWidget {
  final VoidCallback? onDone;

  const _CongratsDialogContent({this.onDone});

  @override
  State<_CongratsDialogContent> createState() => _CongratsDialogContentState();
}

class _CongratsDialogContentState extends State<_CongratsDialogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _checkScale =
        CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _checkController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Interview Scheduled!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The interview invitation has been sent to the candidate and is awaiting their response.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onDone?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
