import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeePostNewJobPage extends StatefulWidget {
  const EmployeePostNewJobPage({super.key});

  @override
  State<EmployeePostNewJobPage> createState() =>
      _EmployeePostNewJobPageState();
}

class _EmployeePostNewJobPageState extends State<EmployeePostNewJobPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 10;

  final List<String> _stepTitles = const [
    'Basic Information',
    'Employment Information',
    'Salary',
    'Work Schedule',
    'Job Location',
    'Candidate Preferences',
    'Job Description',
    'Application Settings',
    'Job Promotion',
    'Preview & Publish',
  ];

  // ── STEP 1: Basic Information ──
  final _jobTitleCtrl = TextEditingController();
  String? _jobCategory;
  final _jobRoleCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _vacanciesCtrl = TextEditingController();

  final List<String> _categories = const [
    'Delivery / Logistics',
    'Retail / Sales',
    'Housekeeping',
    'Security',
    'Warehouse',
    'Driver',
    'Cook / Kitchen Staff',
    'Other',
  ];

  // ── STEP 2: Employment Information ──
  String? _employmentType;
  String? _jobLevel;
  final _experienceCtrl = TextEditingController();
  String? _qualification;
  final List<String> _skills = [];
  final _skillInputCtrl = TextEditingController();
  final List<String> _languages = [];
  final _languageInputCtrl = TextEditingController();

  final List<String> _employmentTypes = const [
    'Full-time', 'Part-time', 'Contract', 'Temporary',
    'Internship', 'Freelance', 'Gig', 'Apprenticeship',
  ];
  final List<String> _jobLevels = const [
    'Entry Level', 'Mid Level', 'Senior Level', 'Manager', 'Executive',
  ];
  final List<String> _qualifications = const [
    '10th Pass', '12th Pass', 'Diploma', 'Graduate', 'Post Graduate', 'Any',
  ];

  // ── STEP 3: Salary ──
  final _minSalaryCtrl = TextEditingController();
  final _maxSalaryCtrl = TextEditingController();
  String? _salaryFrequency;
  bool _negotiable = false;
  bool _hideSalary = false;

  final List<String> _salaryFrequencies = const [
    'Hourly', 'Daily', 'Weekly', 'Monthly', 'Annual',
  ];

  // ── STEP 4: Work Schedule ──
  final Set<String> _workingDays = {};
  String? _shiftType;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _weeklyOff;
  bool _overtimeAvailable = false;

  final List<String> _weekDays = const [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  final List<String> _shiftTypes = const [
    'Day shift', 'Night shift', 'Rotational shift', 'Flexible shift',
  ];

  // ── STEP 5: Job Location ──
  final _countryCtrl = TextEditingController(text: 'India');
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  String? _savedBranch;

  final List<String> _savedBranches = const [
    'Head Office', 'Branch 1', 'Branch 2',
  ];

  // ── STEP 6: Candidate Preferences ──
  final _minAgeCtrl = TextEditingController();
  final _maxAgeCtrl = TextEditingController();
  String? _preferredGender;
  final _reqExperienceCtrl = TextEditingController();
  final _reqEducationCtrl = TextEditingController();
  final List<String> _mandatorySkills = [];
  final _mandatorySkillInputCtrl = TextEditingController();
  final List<String> _preferredLanguages = [];
  final _preferredLangInputCtrl = TextEditingController();
  bool _immediateJoining = false;
  bool _localCandidatePreference = false;

  final List<String> _genderOptions = const ['Any', 'Male', 'Female', 'Other'];

  // ── STEP 7: Job Description ──
  final _jobSummaryCtrl = TextEditingController();
  final _responsibilitiesCtrl = TextEditingController();
  final _requiredSkillsDescCtrl = TextEditingController();
  final _benefitsCtrl = TextEditingController();
  final _additionalInfoCtrl = TextEditingController();

  bool _showAiAssistant = false;
  final _aiIndustryCtrl = TextEditingController();
  final _aiExperienceCtrl = TextEditingController();
  final _aiMainResponsibilitiesCtrl = TextEditingController();

  // ── STEP 8: Application Settings ──
  DateTime? _acceptUntilDate;
  final _maxApplicationsCtrl = TextEditingController();
  final List<String> _screeningQuestions = [];
  final _screeningInputCtrl = TextEditingController();
  bool _resumeMandatory = true;
  bool _videoResumeRequired = false;
  final _autoResponseCtrl = TextEditingController();
  String? _applicationVisibility;

  final List<String> _visibilityOptions = const [
    'Public', 'Private', 'Invite-only',
  ];

  // ── STEP 9: Job Promotion ──
  bool _featuredJob = false;
  bool _urgentHiring = false;
  bool _topSearchPlacement = false;
  bool _homepagePlacement = false;
  bool _nearbyNotification = false;

  @override
  void dispose() {
    _pageController.dispose();
    _jobTitleCtrl.dispose();
    _jobRoleCtrl.dispose();
    _departmentCtrl.dispose();
    _vacanciesCtrl.dispose();
    _experienceCtrl.dispose();
    _skillInputCtrl.dispose();
    _languageInputCtrl.dispose();
    _minSalaryCtrl.dispose();
    _maxSalaryCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _localityCtrl.dispose();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _minAgeCtrl.dispose();
    _maxAgeCtrl.dispose();
    _reqExperienceCtrl.dispose();
    _reqEducationCtrl.dispose();
    _mandatorySkillInputCtrl.dispose();
    _preferredLangInputCtrl.dispose();
    _jobSummaryCtrl.dispose();
    _responsibilitiesCtrl.dispose();
    _requiredSkillsDescCtrl.dispose();
    _benefitsCtrl.dispose();
    _additionalInfoCtrl.dispose();
    _aiIndustryCtrl.dispose();
    _aiExperienceCtrl.dispose();
    _aiMainResponsibilitiesCtrl.dispose();
    _maxApplicationsCtrl.dispose();
    _screeningInputCtrl.dispose();
    _autoResponseCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────
  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _publish();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _saveAsDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved as draft')),
    );
  }

  void _publish() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job published successfully')),
    );
  }

  // ─────────────────────────────────────────────
  // SHARED UI HELPERS (compact spacing)
  // ─────────────────────────────────────────────
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _gap([double h = 14]) => SizedBox(height: h);

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13.5),
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: _decoration(hint),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String hint = 'Select',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary),
          decoration: _decoration(hint),
          items: items
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c,
                        style: const TextStyle(
                            fontSize: 13.5, color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _sectionNote(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.coralSoft.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.coral),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _singleChipSelector(
    String label,
    List<String> options,
    String? selected,
    ValueChanged<String> onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.buttonText : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _multiChipSelector(
    String label,
    List<String> options,
    Set<String> selected,
    ValueChanged<String> onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            return GestureDetector(
              onTap: () => onToggle(opt),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.buttonText : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _tagInput(
    String label,
    String hint,
    List<String> tags,
    TextEditingController inputCtrl,
  ) {
    void addTag() {
      final val = inputCtrl.text.trim();
      if (val.isNotEmpty && !tags.contains(val)) {
        setState(() {
          tags.add(val);
          inputCtrl.clear();
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: inputCtrl,
          decoration: _decoration(hint).copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle,
                  color: AppColors.primary, size: 22),
              onPressed: addTag,
            ),
          ),
          onSubmitted: (_) => addTag(),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary)),
                backgroundColor: AppColors.primary.withOpacity(0.08),
                deleteIcon: const Icon(Icons.close,
                    size: 15, color: AppColors.primary),
                onDeleted: () => setState(() => tags.remove(tag)),
                side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _stepCard(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STEP BUILDERS
  // ─────────────────────────────────────────────
  Widget _buildStep1() {
    return _stepCard([
      _textField('Job Title *', _jobTitleCtrl, 'e.g. Sales Executive'),
      _gap(),
      _dropdown('Job Category *', _jobCategory, _categories,
          (v) => setState(() => _jobCategory = v)),
      _gap(),
      _textField('Job Role', _jobRoleCtrl, 'e.g. Field Sales Representative'),
      _gap(),
      _textField('Department', _departmentCtrl, 'e.g. Sales & Marketing'),
      _gap(),
      _textField('Number of Vacancies *', _vacanciesCtrl, 'e.g. 10',
          keyboardType: TextInputType.number),
    ]);
  }

  Widget _buildStep2() {
    return _stepCard([
      _singleChipSelector('Employment Type *', _employmentTypes,
          _employmentType, (v) => setState(() => _employmentType = v)),
      _gap(),
      _dropdown('Job Level', _jobLevel, _jobLevels,
          (v) => setState(() => _jobLevel = v)),
      _gap(),
      _textField('Experience Required', _experienceCtrl, 'e.g. 2-4 years'),
      _gap(),
      _dropdown('Qualification', _qualification, _qualifications,
          (v) => setState(() => _qualification = v)),
      _gap(),
      _tagInput('Skills', 'Type a skill and press +', _skills,
          _skillInputCtrl),
      _gap(),
      _tagInput('Language Requirements', 'Type a language and press +',
          _languages, _languageInputCtrl),
    ]);
  }

  Widget _buildStep3() {
    return _stepCard([
      Row(
        children: [
          Expanded(
              child: _textField('Minimum Salary', _minSalaryCtrl, '₹ 15,000',
                  keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(
              child: _textField('Maximum Salary', _maxSalaryCtrl, '₹ 25,000',
                  keyboardType: TextInputType.number)),
        ],
      ),
      _gap(),
      _dropdown('Salary Frequency', _salaryFrequency, _salaryFrequencies,
          (v) => setState(() => _salaryFrequency = v)),
      _gap(),
      _switchTile('Negotiable', _negotiable,
          (v) => setState(() => _negotiable = v)),
      _switchTile('Hide salary from candidates', _hideSalary,
          (v) => setState(() => _hideSalary = v)),
      _sectionNote(
          'Hiding salary is allowed only where platform policy permits it.'),
    ]);
  }

  Widget _buildStep4() {
    return _stepCard([
      _multiChipSelector('Working Days', _weekDays, _workingDays,
          (day) => setState(() {
                _workingDays.contains(day)
                    ? _workingDays.remove(day)
                    : _workingDays.add(day);
              })),
      _gap(),
      _singleChipSelector('Shift Type', _shiftTypes, _shiftType,
          (v) => setState(() => _shiftType = v)),
      _gap(),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Start Time'),
                InkWell(
                  onTap: () async {
                    final t = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (t != null) setState(() => _startTime = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _startTime?.format(context) ?? 'Select time',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: _startTime == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
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
                _label('End Time'),
                InkWell(
                  onTap: () async {
                    final t = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (t != null) setState(() => _endTime = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _endTime?.format(context) ?? 'Select time',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: _endTime == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      _gap(),
      _dropdown('Weekly Off', _weeklyOff, _weekDays,
          (v) => setState(() => _weeklyOff = v)),
      _gap(),
      _switchTile('Overtime Availability', _overtimeAvailable,
          (v) => setState(() => _overtimeAvailable = v)),
    ]);
  }

  Widget _buildStep5() {
    return _stepCard([
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _actionChip(Icons.my_location, 'Use Current Location', () {
            setState(() {
              _latCtrl.text = '19.0760';
              _lngCtrl.text = '72.8777';
            });
          }),
          _actionChip(Icons.search, 'Search Location', () {}),
          _actionChip(Icons.map_outlined, 'Select on Map', () {}),
        ],
      ),
      _gap(),
      _dropdown('Use Saved Branch', _savedBranch, _savedBranches,
          (v) => setState(() => _savedBranch = v)),
      _gap(),
      Row(
        children: [
          Expanded(child: _textField('Country', _countryCtrl, 'Country')),
          const SizedBox(width: 12),
          Expanded(child: _textField('State', _stateCtrl, 'State')),
        ],
      ),
      _gap(),
      Row(
        children: [
          Expanded(child: _textField('City', _cityCtrl, 'City')),
          const SizedBox(width: 12),
          Expanded(child: _textField('Locality', _localityCtrl, 'Locality')),
        ],
      ),
      _gap(),
      _textField('Full Address', _addressCtrl, 'House no, street, area',
          maxLines: 2),
      _gap(),
      _textField('Landmark', _landmarkCtrl, 'e.g. Near City Mall'),
      _gap(),
      Row(
        children: [
          Expanded(
              child: _textField('Latitude', _latCtrl, 'Auto / manual',
                  keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(
              child: _textField('Longitude', _lngCtrl, 'Auto / manual',
                  keyboardType: TextInputType.number)),
        ],
      ),
    ]);
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep6() {
    return _stepCard([
      Row(
        children: [
          Expanded(
              child: _textField('Minimum Age', _minAgeCtrl, 'e.g. 18',
                  keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(
              child: _textField('Maximum Age', _maxAgeCtrl, 'e.g. 45',
                  keyboardType: TextInputType.number)),
        ],
      ),
      _gap(),
      _dropdown('Preferred Gender', _preferredGender, _genderOptions,
          (v) => setState(() => _preferredGender = v)),
      _gap(),
      _textField(
          'Required Experience', _reqExperienceCtrl, 'e.g. 1+ years'),
      _gap(),
      _textField('Required Education', _reqEducationCtrl, 'e.g. Graduate'),
      _gap(),
      _tagInput('Mandatory Skills', 'Type a skill and press +',
          _mandatorySkills, _mandatorySkillInputCtrl),
      _gap(),
      _tagInput('Preferred Languages', 'Type a language and press +',
          _preferredLanguages, _preferredLangInputCtrl),
      _gap(),
      _switchTile('Immediate Joining', _immediateJoining,
          (v) => setState(() => _immediateJoining = v)),
      _switchTile('Local Candidate Preference', _localCandidatePreference,
          (v) => setState(() => _localCandidatePreference = v)),
      _sectionNote(
          'Candidate eligibility filters must comply with applicable employment and anti-discrimination laws. Prohibited or discriminatory criteria are not allowed.'),
    ]);
  }

  Widget _buildStep7() {
    return _stepCard([
      InkWell(
        onTap: () => setState(() => _showAiAssistant = !_showAiAssistant),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AI Job Description Assistant',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
              Icon(
                _showAiAssistant ? Icons.expand_less : Icons.expand_more,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
      if (_showAiAssistant) ...[
        _gap(12),
        _textField('Industry', _aiIndustryCtrl, 'e.g. Retail'),
        _gap(12),
        _textField('Experience', _aiExperienceCtrl, 'e.g. 2 years'),
        _gap(12),
        _textField('Main Responsibilities', _aiMainResponsibilitiesCtrl,
            'e.g. Handling customer sales', maxLines: 2),
        _gap(12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _jobSummaryCtrl.text =
                    'We are looking for a motivated ${_jobTitleCtrl.text.isEmpty ? "professional" : _jobTitleCtrl.text} to join our team in the ${_aiIndustryCtrl.text.isEmpty ? "industry" : _aiIndustryCtrl.text} sector.';
                _responsibilitiesCtrl.text = _aiMainResponsibilitiesCtrl.text;
                _requiredSkillsDescCtrl.text = _skills.join(', ');
              });
            },
            icon: const Icon(Icons.auto_awesome,
                size: 16, color: AppColors.primary),
            label: const Text('Generate with AI',
                style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
      _gap(),
      _textField('Job Summary *', _jobSummaryCtrl, 'Brief overview of the job',
          maxLines: 3),
      _gap(),
      _textField('Responsibilities', _responsibilitiesCtrl,
          'Key duties for this role', maxLines: 3),
      _gap(),
      _textField('Required Skills', _requiredSkillsDescCtrl,
          'List of required skills', maxLines: 2),
      _gap(),
      _textField('Benefits', _benefitsCtrl, 'e.g. PF, ESI, Incentives',
          maxLines: 2),
      _gap(),
      _textField('Additional Information', _additionalInfoCtrl,
          'Anything else candidates should know', maxLines: 2),
    ]);
  }

  Widget _buildStep8() {
    return _stepCard([
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Accept Applications Until'),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 15)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _acceptUntilDate = d);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _acceptUntilDate == null
                    ? 'Select date'
                    : '${_acceptUntilDate!.day}/${_acceptUntilDate!.month}/${_acceptUntilDate!.year}',
                style: TextStyle(
                  fontSize: 13.5,
                  color: _acceptUntilDate == null
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      _gap(),
      _textField('Maximum Applications', _maxApplicationsCtrl, 'e.g. 100',
          keyboardType: TextInputType.number),
      _gap(),
      _tagInput('Screening Questions', 'Type a question and press +',
          _screeningQuestions, _screeningInputCtrl),
      _gap(),
      _switchTile('Resume Mandatory', _resumeMandatory,
          (v) => setState(() => _resumeMandatory = v)),
      _switchTile('Video Resume Required', _videoResumeRequired,
          (v) => setState(() => _videoResumeRequired = v)),
      _gap(),
      _textField('Auto-response Message', _autoResponseCtrl,
          'Message sent to applicants automatically', maxLines: 2),
      _gap(),
      _dropdown('Application Visibility', _applicationVisibility,
          _visibilityOptions, (v) => setState(() => _applicationVisibility = v)),
    ]);
  }

  Widget _buildStep9() {
    return _stepCard([
      _promoTile('Featured Job', 'Highlight this job in listings',
          _featuredJob, (v) => setState(() => _featuredJob = v)),
      _promoTile('Urgent Hiring Badge', 'Show an urgent hiring tag',
          _urgentHiring, (v) => setState(() => _urgentHiring = v)),
      _promoTile('Top Search Placement', 'Appear at the top of search results',
          _topSearchPlacement, (v) => setState(() => _topSearchPlacement = v)),
      _promoTile('Homepage Placement', 'Feature this job on the homepage',
          _homepagePlacement, (v) => setState(() => _homepagePlacement = v)),
      _promoTile(
          'Nearby Candidate Notification',
          'Notify nearby candidates about this job',
          _nearbyNotification,
          (v) => setState(() => _nearbyNotification = v)),
      _sectionNote('These are optional paid promotions. Charges will be shown before publishing.'),
    ]);
  }

  Widget _promoTile(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, activeThumbColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildStep10() {
    final promotionsSelected = [
      if (_featuredJob) 'Featured Job',
      if (_urgentHiring) 'Urgent Hiring Badge',
      if (_topSearchPlacement) 'Top Search Placement',
      if (_homepagePlacement) 'Homepage Placement',
      if (_nearbyNotification) 'Nearby Candidate Notification',
    ];
    final mandatoryFilled = _jobTitleCtrl.text.isNotEmpty &&
        _jobCategory != null &&
        _vacanciesCtrl.text.isNotEmpty &&
        _employmentType != null &&
        _jobSummaryCtrl.text.isNotEmpty;

    return _stepCard([
      _previewCard('Basic Details', [
        'Title: ${_jobTitleCtrl.text.isEmpty ? "-" : _jobTitleCtrl.text}',
        'Category: ${_jobCategory ?? "-"}',
        'Vacancies: ${_vacanciesCtrl.text.isEmpty ? "-" : _vacanciesCtrl.text}',
      ]),
      _gap(10),
      _previewCard('Employment', [
        'Type: ${_employmentType ?? "-"}',
        'Level: ${_jobLevel ?? "-"}',
        'Skills: ${_skills.isEmpty ? "-" : _skills.join(", ")}',
      ]),
      _gap(10),
      _previewCard('Salary', [
        '${_minSalaryCtrl.text.isEmpty ? "-" : _minSalaryCtrl.text} - ${_maxSalaryCtrl.text.isEmpty ? "-" : _maxSalaryCtrl.text} (${_salaryFrequency ?? "-"})',
        _hideSalary ? 'Hidden from candidates' : 'Visible to candidates',
      ]),
      _gap(10),
      _previewCard('Location', [
        '${_localityCtrl.text.isEmpty ? "-" : _localityCtrl.text}, ${_cityCtrl.text.isEmpty ? "-" : _cityCtrl.text}, ${_stateCtrl.text.isEmpty ? "-" : _stateCtrl.text}',
      ]),
      _gap(10),
      _previewCard('Promotions', [
        promotionsSelected.isEmpty ? 'None selected' : promotionsSelected.join(', '),
      ]),
      _gap(14),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mandatoryFilled
              ? AppColors.mintSoft
              : AppColors.pinkSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              mandatoryFilled ? Icons.check_circle : Icons.error_outline,
              size: 18,
              color: mandatoryFilled ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mandatoryFilled
                    ? 'All mandatory fields are filled'
                    : 'Some mandatory fields are missing',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: mandatoryFilled ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
      _gap(10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan Usage',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            SizedBox(height: 4),
            Text('4 of 10 job posts used this month',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
      _gap(20),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _saveAsDraft,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save as Draft',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Publish',
                  style: TextStyle(color: AppColors.buttonText, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _previewCard(String title, List<String> lines) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 6),
          ...lines.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(l,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
              )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildStep1(),
      _buildStep2(),
      _buildStep3(),
      _buildStep4(),
      _buildStep5(),
      _buildStep6(),
      _buildStep7(),
      _buildStep8(),
      _buildStep9(),
      _buildStep10(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Post New Job",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _stepTitles[_currentStep],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      minHeight: 5,
                      backgroundColor: AppColors.accentsSoft[0],
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: steps,
              ),
            ),
            // Bottom navigation
            if (_currentStep != _totalSteps - 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _goNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Next',
                            style: TextStyle(
                                color: AppColors.buttonText,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}