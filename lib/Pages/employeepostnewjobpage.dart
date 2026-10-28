import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'package:hyper_local_employee/utils/company_profile_gate.dart';
import '../models/job_post_model.dart';
import '../controllers/job_post_controller.dart';
import '../services/user_session.dart';

class EmployeePostNewJobPage extends StatefulWidget {
  final JobPostModel? jobToEdit;

  const EmployeePostNewJobPage({super.key, this.jobToEdit});

  @override
  State<EmployeePostNewJobPage> createState() =>
      _EmployeePostNewJobPageState();
}

class _EmployeePostNewJobPageState extends State<EmployeePostNewJobPage> {
  final PageController _pageController = PageController();
  final JobPostController _jobPostController = JobPostController();
  bool _isSubmitting = false;
  int _currentStep = 0;
  final int _totalSteps = 9;

  final List<String> _stepTitles = const [
    'Basic Info',
    'Skills & Experience',
    'Salary & Timing',
    'Location',
    'Eligibility',
    'Description',
    'Application Settings',
    'Visibility & Promotion',
    'Preview & Submit',
  ];

  // ─────────────────────────────────────────────
  // 1. BASIC INFO
  // ─────────────────────────────────────────────
  final _jobTitleCtrl = TextEditingController();
  String? _jobCategory;
  final _jobRoleCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _vacanciesCtrl = TextEditingController();
  final _remainingVacanciesCtrl = TextEditingController();
  String? _employmentType;
  String? _jobLevel;

  List<String> _categories = [
    'IT & Software',
    'Delivery / Logistics',
    'Retail / Sales',
    'Housekeeping',
    'Security',
    'Warehouse',
    'Driver',
    'Cook / Kitchen Staff',
    'Customer Support',
    'Finance / Accounting',
    'Marketing',
    'Human Resources',
    'Healthcare',
    'Education / Teaching',
    'Other',
  ];

  final List<String> _employmentTypes = const [
    'Full-time',
    'Part-time',
    'Contract',
    'Temporary',
    'Internship',
    'Freelance',
    'Gig',
    'Apprenticeship',
    'Work From Home',
  ];

  final List<String> _jobLevels = const [
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Manager',
    'Executive',
  ];

  // ─────────────────────────────────────────────
  // 2. SKILLS & EXPERIENCE
  // ─────────────────────────────────────────────
  final _experienceCtrl = TextEditingController();
  String? _qualification;
  final List<String> _skills = [];
  final _skillInputCtrl = TextEditingController();
  final List<String> _languages = [];
  final _languageInputCtrl = TextEditingController();
  final List<String> _mandatorySkills = [];
  final _mandatorySkillInputCtrl = TextEditingController();
  final List<String> _preferredLanguages = [];
  final _preferredLangInputCtrl = TextEditingController();

  final List<String> _qualifications = const [
    '10th Pass',
    '12th Pass',
    'Diploma',
    'Graduate',
    'Post Graduate',
    'Doctorate',
    'Any',
  ];

  final List<String> _quickSkills = const [
    'Communication',
    'Customer Service',
    'Sales',
    'Teamwork',
    'Management',
    'Problem Solving',
  ];

  final List<String> _quickLanguages = const [
    'English',
    'Hindi',
    'Marathi',
    'Tamil',
    'Telugu',
    'Gujarati',
    'Bengali',
  ];

  // ─────────────────────────────────────────────
  // 3. SALARY & TIMING
  // ─────────────────────────────────────────────
  final _minSalaryCtrl = TextEditingController();
  final _maxSalaryCtrl = TextEditingController();
  String? _salaryFrequency = 'Monthly';
  bool _negotiable = false;
  bool _hideSalary = false;
  final Set<String> _workingDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'};
  String? _shiftType = 'Day shift';
  TimeOfDay? _startTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay? _endTime = const TimeOfDay(hour: 18, minute: 30);
  String? _weeklyOff = 'Sunday';
  bool _overtimeAvailable = false;

  final List<String> _salaryFrequencies = const [
    'Monthly',
    'Weekly',
    'Daily',
    'Hourly',
    'Annual',
  ];

  final List<String> _weekDays = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final List<String> _shiftTypes = const [
    'Day shift',
    'Night shift',
    'Rotational shift',
    'Flexible shift',
  ];

  final List<String> _weeklyOffOptions = const [
    'Sunday',
    'Saturday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Rotational',
    'None',
  ];

  // ─────────────────────────────────────────────
  // 4. LOCATION
  // ─────────────────────────────────────────────
  final _countryCtrl = TextEditingController(text: 'India');
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateIdCtrl = TextEditingController();
  final _cityIdCtrl = TextEditingController();
  int? _selectedStateId;
  int? _selectedCityId;
  List<Map<String, dynamic>> _apiStates = [];
  List<Map<String, dynamic>> _apiCities = [];

  final _localityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _distanceKmCtrl = TextEditingController();
  final _branchIdCtrl = TextEditingController();
  String? _savedBranch;

  final List<String> _savedBranches = const [
    'Head Office',
    'Branch 1',
    'Branch 2',
  ];

  static const Map<String, Map<String, double>> _cityCoordinateMap = {
    'amravati': {'lat': 20.9374, 'lng': 77.7796},
    'mumbai': {'lat': 19.0760, 'lng': 72.8777},
    'pune': {'lat': 18.5204, 'lng': 73.8567},
    'nagpur': {'lat': 21.1458, 'lng': 79.0882},
    'nashik': {'lat': 20.0059, 'lng': 73.7898},
    'aurangabad': {'lat': 19.8762, 'lng': 75.3433},
    'chhatrapati sambhajinagar': {'lat': 19.8762, 'lng': 75.3433},
    'thane': {'lat': 19.2183, 'lng': 72.9781},
    'solapur': {'lat': 17.6599, 'lng': 75.9064},
    'kolhapur': {'lat': 16.7050, 'lng': 74.2433},
    'sangli': {'lat': 16.8524, 'lng': 74.5815},
    'nanded': {'lat': 19.1383, 'lng': 77.3210},
    'jalgaon': {'lat': 21.0077, 'lng': 75.5626},
    'akola': {'lat': 20.7002, 'lng': 77.0082},
    'latur': {'lat': 18.4088, 'lng': 76.5604},
    'dhule': {'lat': 20.9042, 'lng': 74.7749},
    'ahmednagar': {'lat': 19.0948, 'lng': 74.7480},
    'ahilyanagar': {'lat': 19.0948, 'lng': 74.7480},
    'chandrapur': {'lat': 19.9615, 'lng': 79.2961},
    'parbhani': {'lat': 19.2686, 'lng': 76.7709},
    'ichalkaranji': {'lat': 16.6966, 'lng': 74.4578},
    'jalna': {'lat': 19.8347, 'lng': 75.8816},
    'yavatmal': {'lat': 20.3888, 'lng': 78.1204},
    'satara': {'lat': 17.6805, 'lng': 74.0183},
    'beed': {'lat': 18.9891, 'lng': 75.7601},
    'gondia': {'lat': 21.4624, 'lng': 80.1961},
    'bhandara': {'lat': 21.1697, 'lng': 79.6548},
    'buldhana': {'lat': 20.5293, 'lng': 76.1843},
    'washim': {'lat': 20.1062, 'lng': 77.1333},
    'wardha': {'lat': 20.7453, 'lng': 78.6022},
    'gadchiroli': {'lat': 20.1849, 'lng': 79.9948},
    'nandurbar': {'lat': 21.3703, 'lng': 74.2402},
    'ratnagiri': {'lat': 16.9902, 'lng': 73.3120},
    'sindhudurg': {'lat': 16.1478, 'lng': 73.6811},
    'navi mumbai': {'lat': 19.0330, 'lng': 73.0297},
    'delhi': {'lat': 28.6139, 'lng': 77.2090},
    'bengaluru': {'lat': 12.9716, 'lng': 77.5946},
    'bangalore': {'lat': 12.9716, 'lng': 77.5946},
    'hyderabad': {'lat': 17.3850, 'lng': 78.4867},
    'chennai': {'lat': 13.0827, 'lng': 80.2707},
    'kolkata': {'lat': 22.5726, 'lng': 88.3639},
    'ahmedabad': {'lat': 23.0225, 'lng': 72.5714},
    'surat': {'lat': 21.1702, 'lng': 72.8311},
    'jaipur': {'lat': 26.9124, 'lng': 75.7873},
    'indore': {'lat': 22.7196, 'lng': 75.8577},
    'bhopal': {'lat': 23.2599, 'lng': 77.4126},
  };

  static const Map<String, Map<String, double>> _stateCoordinateMap = {
    'maharashtra': {'lat': 19.7515, 'lng': 75.7139},
    'goa': {'lat': 15.2993, 'lng': 74.1240},
    'gujarat': {'lat': 22.2587, 'lng': 71.1924},
    'madhya pradesh': {'lat': 22.9734, 'lng': 78.6569},
    'karnataka': {'lat': 15.3173, 'lng': 75.7139},
    'telangana': {'lat': 18.1124, 'lng': 79.0193},
    'delhi': {'lat': 28.6139, 'lng': 77.2090},
  };

  void _autoFillLatLng({String? state, String? city}) {
    final sName = (state ?? _stateCtrl.text).trim().toLowerCase();
    final cName = (city ?? _cityCtrl.text).trim().toLowerCase();

    if (cName.isNotEmpty) {
      if (_cityCoordinateMap.containsKey(cName)) {
        final coords = _cityCoordinateMap[cName]!;
        _latCtrl.text = coords['lat']!.toString();
        _lngCtrl.text = coords['lng']!.toString();
        return;
      }
      for (final entry in _cityCoordinateMap.entries) {
        if (entry.key.length >= 3 && (cName.contains(entry.key) || entry.key.contains(cName))) {
          _latCtrl.text = entry.value['lat']!.toString();
          _lngCtrl.text = entry.value['lng']!.toString();
          return;
        }
      }
    }

    if (sName.isNotEmpty) {
      if (_stateCoordinateMap.containsKey(sName)) {
        final coords = _stateCoordinateMap[sName]!;
        _latCtrl.text = coords['lat']!.toString();
        _lngCtrl.text = coords['lng']!.toString();
        return;
      }
      for (final entry in _stateCoordinateMap.entries) {
        if (entry.key.length >= 3 && (sName.contains(entry.key) || entry.key.contains(sName))) {
          _latCtrl.text = entry.value['lat']!.toString();
          _lngCtrl.text = entry.value['lng']!.toString();
          return;
        }
      }
    }
  }

  // ─────────────────────────────────────────────
  // 5. ELIGIBILITY
  // ─────────────────────────────────────────────
  final _minAgeCtrl = TextEditingController();
  final _maxAgeCtrl = TextEditingController();
  String? _preferredGender = 'Any';
  final _reqExperienceCtrl = TextEditingController();
  final _reqEducationCtrl = TextEditingController();
  bool _immediateJoining = false;
  bool _localCandidatePreference = false;

  final List<String> _genderOptions = const ['Any', 'Male', 'Female'];

  // ─────────────────────────────────────────────
  // 6. DESCRIPTION
  // ─────────────────────────────────────────────
  final _companyNameCtrl = TextEditingController();
  final _companyInitialCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController(text: '4.5');
  final _reviewsCountCtrl = TextEditingController(text: '0');
  DateTime? _postedOnDate = DateTime.now();
  final _jobSummaryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _responsibilitiesCtrl = TextEditingController();
  final _requiredSkillsDescCtrl = TextEditingController();
  final _benefitsCtrl = TextEditingController();
  final _additionalInfoCtrl = TextEditingController();

  bool _showAiAssistant = false;
  final _aiIndustryCtrl = TextEditingController();
  final _aiExperienceCtrl = TextEditingController();
  final _aiMainResponsibilitiesCtrl = TextEditingController();

  // ─────────────────────────────────────────────
  // 7. APPLICATION SETTINGS
  // ─────────────────────────────────────────────
  DateTime? _acceptUntilDate = DateTime.now().add(const Duration(days: 30));
  final _maxApplicationsCtrl = TextEditingController();
  final List<String> _screeningQuestions = [];
  final _screeningInputCtrl = TextEditingController();
  bool _resumeMandatory = true;
  bool _videoResumeRequired = false;
  final _autoResponseCtrl = TextEditingController();
  String? _applicationVisibility = 'Public';

  final List<String> _visibilityOptions = const [
    'Public',
    'Private',
    'Invite-only',
  ];

  // ─────────────────────────────────────────────
  // 8. VISIBILITY & PROMOTION
  // ─────────────────────────────────────────────
  bool _featuredJob = false;
  bool _premiumJob = false;
  bool _walkInInterview = false;
  bool _urgentHiring = false;
  bool _topSearchPlacement = false;
  bool _homepagePlacement = false;
  bool _nearbyNotification = false;

  Future<void> _checkInitialProfileCompletion() async {
    final canProceed = await CompanyProfileGate.ensureProfileComplete(context);
    if (!canProceed && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkInitialProfileCompletion();
      });
    }
    _fetchLocationData();
    _fetchCategories();
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      _jobTitleCtrl.text = job.jobTitle ?? '';
      _jobCategory = job.jobCategory;
      _jobRoleCtrl.text = job.jobRole ?? '';
      _departmentCtrl.text = job.department ?? '';
      _vacanciesCtrl.text = job.numberOfVacancies != null ? job.numberOfVacancies.toString() : '';
      _remainingVacanciesCtrl.text = job.remainingVacancies != null ? job.remainingVacancies.toString() : '';
      _employmentType = job.employmentType;
      _jobLevel = job.jobLevel;

      _experienceCtrl.text = job.experienceRequired ?? '';
      _qualification = job.qualification;
      _skills.addAll(job.skills);
      _languages.addAll(job.languageRequirements);
      _mandatorySkills.addAll(job.mandatorySkills);
      _preferredLanguages.addAll(job.preferredLanguages);

      _minSalaryCtrl.text = job.minSalary != null ? job.minSalary.toString() : '';
      _maxSalaryCtrl.text = job.maxSalary != null ? job.maxSalary.toString() : '';
      _salaryFrequency = job.salaryFrequency ?? 'Monthly';
      _negotiable = job.isNegotiable;
      _hideSalary = job.hideSalary;
      _workingDays.clear();
      _workingDays.addAll(job.workingDays);
      _shiftType = job.shiftType ?? 'Day shift';
      if (job.startTime != null && job.startTime!.isNotEmpty) {
        final parts = job.startTime!.split(':');
        if (parts.length >= 2) {
          _startTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 30);
        }
      }
      if (job.endTime != null && job.endTime!.isNotEmpty) {
        final parts = job.endTime!.split(':');
        if (parts.length >= 2) {
          _endTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 18, minute: int.tryParse(parts[1]) ?? 30);
        }
      }
      _weeklyOff = job.weeklyOff ?? 'Sunday';
      _overtimeAvailable = job.overtimeAvailability;

      _countryCtrl.text = job.country;
      _stateCtrl.text = job.state ?? '';
      _cityCtrl.text = job.city ?? '';
      _stateIdCtrl.text = job.stateId != null ? job.stateId.toString() : '';
      _cityIdCtrl.text = job.cityId != null ? job.cityId.toString() : '';
      _selectedStateId = job.stateId;
      _selectedCityId = job.cityId;
      _localityCtrl.text = job.locality ?? '';
      _locationCtrl.text = job.location ?? '';
      _addressCtrl.text = job.fullAddress ?? '';
      _landmarkCtrl.text = job.landmark ?? '';
      _latCtrl.text = job.latitude != null ? job.latitude.toString() : '';
      _lngCtrl.text = job.longitude != null ? job.longitude.toString() : '';
      _distanceKmCtrl.text = job.distanceKm != null ? job.distanceKm.toString() : '';
      _branchIdCtrl.text = job.branchId != null ? job.branchId.toString() : '';

      _minAgeCtrl.text = job.minAge != null ? job.minAge.toString() : '';
      _maxAgeCtrl.text = job.maxAge != null ? job.maxAge.toString() : '';
      _preferredGender = job.preferredGender ?? 'Any';
      _reqExperienceCtrl.text = job.requiredExperience ?? '';
      _reqEducationCtrl.text = job.requiredEducation ?? '';
      _immediateJoining = job.immediateJoining;
      _localCandidatePreference = job.localCandidatePreference;

      _companyNameCtrl.text = job.companyName ?? '';
      _companyInitialCtrl.text = job.companyInitial ?? '';
      if (_companyNameCtrl.text.trim().isEmpty && UserSession.companyName.isNotEmpty) {
        _companyNameCtrl.text = UserSession.companyName;
        _companyInitialCtrl.text = UserSession.companyInitials;
      } else if (_companyInitialCtrl.text.trim().isEmpty && _companyNameCtrl.text.isNotEmpty) {
        _companyInitialCtrl.text = UserSession.getInitials(_companyNameCtrl.text);
      }
      _ratingCtrl.text = job.rating != null ? job.rating.toString() : '4.5';
      _reviewsCountCtrl.text = job.reviewsCount != null ? job.reviewsCount.toString() : '0';
      if (job.postedOn != null && job.postedOn!.isNotEmpty) {
        _postedOnDate = DateTime.tryParse(job.postedOn!) ?? DateTime.now();
      }
      _jobSummaryCtrl.text = job.jobSummary ?? '';
      _descriptionCtrl.text = job.description ?? '';
      _responsibilitiesCtrl.text = job.responsibilities ?? '';
      _requiredSkillsDescCtrl.text = job.requiredSkillsDesc ?? '';
      _benefitsCtrl.text = job.benefits ?? '';
      _additionalInfoCtrl.text = job.additionalInformation ?? '';

      if (job.acceptApplicationsUntil != null && job.acceptApplicationsUntil!.isNotEmpty) {
        _acceptUntilDate = DateTime.tryParse(job.acceptApplicationsUntil!);
      }
      _maxApplicationsCtrl.text = job.maximumApplications != null ? job.maximumApplications.toString() : '';
      _screeningQuestions.addAll(job.screeningQuestions);
      _resumeMandatory = job.resumeMandatory;
      _videoResumeRequired = job.videoResumeRequired;
      _autoResponseCtrl.text = job.autoResponseMessage ?? '';
      _applicationVisibility = job.applicationVisibility ?? 'Public';

      _featuredJob = job.isFeatured;
      _premiumJob = job.isPremium;
      _walkInInterview = job.isWalkInInterview;
      _urgentHiring = job.isUrgentHiring;
      _topSearchPlacement = job.topSearchPlacement;
      _homepagePlacement = job.homepagePlacement;
      _nearbyNotification = job.nearbyCandidateNotification;
    } else {
      // Prefill company name / initials from signup business name or user profile
      final compName = UserSession.companyName;
      if (compName.isNotEmpty) {
        _companyNameCtrl.text = compName;
        _companyInitialCtrl.text = UserSession.companyInitials;
      }
    }
  }

  Future<void> _fetchLocationData() async {
    final states = await ApiService.getStates();
    final cities = await ApiService.getCities();
    if (mounted) {
      setState(() {
        _apiStates = states;
        _apiCities = cities;
      });
    }
  }

  Future<void> _fetchCategories() async {
    final fetched = await ApiService.getCategories();
    if (mounted && fetched.isNotEmpty) {
      setState(() {
        _categories = fetched;
        if (_jobCategory != null && !_categories.contains(_jobCategory)) {
          _categories.add(_jobCategory!);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _jobPostController.dispose();

    // Step 1
    _jobTitleCtrl.dispose();
    _jobRoleCtrl.dispose();
    _departmentCtrl.dispose();
    _vacanciesCtrl.dispose();
    _remainingVacanciesCtrl.dispose();

    // Step 2
    _experienceCtrl.dispose();
    _skillInputCtrl.dispose();
    _languageInputCtrl.dispose();
    _mandatorySkillInputCtrl.dispose();
    _preferredLangInputCtrl.dispose();

    // Step 3
    _minSalaryCtrl.dispose();
    _maxSalaryCtrl.dispose();

    // Step 4
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _stateIdCtrl.dispose();
    _cityIdCtrl.dispose();
    _localityCtrl.dispose();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _locationCtrl.dispose();
    _distanceKmCtrl.dispose();
    _branchIdCtrl.dispose();

    // Step 5
    _minAgeCtrl.dispose();
    _maxAgeCtrl.dispose();
    _reqExperienceCtrl.dispose();
    _reqEducationCtrl.dispose();

    // Step 6
    _companyNameCtrl.dispose();
    _companyInitialCtrl.dispose();
    _ratingCtrl.dispose();
    _reviewsCountCtrl.dispose();
    _jobSummaryCtrl.dispose();
    _descriptionCtrl.dispose();
    _responsibilitiesCtrl.dispose();
    _requiredSkillsDescCtrl.dispose();
    _benefitsCtrl.dispose();
    _additionalInfoCtrl.dispose();
    _aiIndustryCtrl.dispose();
    _aiExperienceCtrl.dispose();
    _aiMainResponsibilitiesCtrl.dispose();

    // Step 7
    _maxApplicationsCtrl.dispose();
    _screeningInputCtrl.dispose();
    _autoResponseCtrl.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────
  // NAVIGATION & ACTIONS
  // ─────────────────────────────────────────────
  void _jumpToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      setState(() => _currentStep = step);
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.coral,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.buttonText, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateMandatoryFields() {
    if (_jobTitleCtrl.text.trim().isEmpty) {
      _showError('Job Title is required');
      _jumpToStep(0);
      return false;
    }
    if (_jobCategory == null || _jobCategory!.trim().isEmpty) {
      _showError('Job Category is required');
      _jumpToStep(0);
      return false;
    }
    final vacancies = int.tryParse(_vacanciesCtrl.text.trim());
    if (vacancies == null || vacancies <= 0) {
      _showError('Number of Vacancies must be at least 1');
      _jumpToStep(0);
      return false;
    }
    if (_employmentType == null || _employmentType!.trim().isEmpty) {
      _showError('Employment Type is required');
      _jumpToStep(0);
      return false;
    }
    return true;
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Map<String, dynamic> _buildPayload({bool asDraft = false}) {
    String? cleanStr(TextEditingController ctrl) {
      final val = ctrl.text.trim();
      return val.isEmpty ? null : val;
    }

    int? cleanInt(TextEditingController ctrl) {
      final val = ctrl.text.trim().replaceAll(',', '');
      return int.tryParse(val);
    }

    double? cleanDouble(TextEditingController ctrl) {
      final val = ctrl.text.trim().replaceAll(',', '');
      return double.tryParse(val);
    }

    final vacancies = cleanInt(_vacanciesCtrl) ?? 1;
    final remainingVacancies = cleanInt(_remainingVacanciesCtrl) ?? vacancies;

    String? locationStr = cleanStr(_locationCtrl);
    if (locationStr == null) {
      final parts = [cleanStr(_localityCtrl), cleanStr(_cityCtrl), cleanStr(_stateCtrl)]
          .where((p) => p != null && p.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        locationStr = parts.join(', ');
      }
    }

    String? compName = cleanStr(_companyNameCtrl);
    String? compInitial = cleanStr(_companyInitialCtrl);
    if ((compInitial == null || compInitial.isEmpty) && compName != null && compName.isNotEmpty) {
      compInitial = compName.substring(0, compName.length > 2 ? 2 : compName.length).toUpperCase();
    }

    return {
      'company_name': compName,
      'company_initial': compInitial,
      'location': locationStr,
      'distance_km': cleanDouble(_distanceKmCtrl) ?? 0.0,
      'rating': cleanDouble(_ratingCtrl) ?? 0.0,
      'reviews_count': cleanInt(_reviewsCountCtrl) ?? 0,
      'posted_on': _postedOnDate != null ? _formatDate(_postedOnDate!) : _formatDate(DateTime.now()),
      'description': cleanStr(_descriptionCtrl) ?? cleanStr(_jobSummaryCtrl),

      'job_title': _jobTitleCtrl.text.trim(),
      'job_category': _jobCategory,
      'job_role': cleanStr(_jobRoleCtrl),
      'department': cleanStr(_departmentCtrl),
      'number_of_vacancies': vacancies,
      'remaining_vacancies': remainingVacancies,

      'employment_type': _employmentType,
      'job_level': _jobLevel,
      'experience_required': cleanStr(_experienceCtrl),
      'qualification': _qualification,
      'skills': List<String>.from(_skills),
      'language_requirements': List<String>.from(_languages),

      'min_salary': cleanInt(_minSalaryCtrl),
      'max_salary': cleanInt(_maxSalaryCtrl),
      'salary_frequency': _salaryFrequency,
      'is_negotiable': _negotiable,
      'hide_salary': _hideSalary,

      'working_days': _workingDays.toList(),
      'shift_type': _shiftType,
      'start_time': _startTime != null ? _formatTime(_startTime!) : null,
      'end_time': _endTime != null ? _formatTime(_endTime!) : null,
      'weekly_off': _weeklyOff,
      'overtime_availability': _overtimeAvailable,

      'branch_id': cleanInt(_branchIdCtrl),

      'country': _countryCtrl.text.trim().isEmpty ? 'India' : _countryCtrl.text.trim(),
      'state_id': cleanInt(_stateIdCtrl) ?? _selectedStateId ?? cleanInt(_stateCtrl),
      'city_id': cleanInt(_cityIdCtrl) ?? _selectedCityId ?? cleanInt(_cityCtrl),
      'state': cleanStr(_stateCtrl),
      'city': cleanStr(_cityCtrl),
      'locality': cleanStr(_localityCtrl),
      'full_address': cleanStr(_addressCtrl),
      'landmark': cleanStr(_landmarkCtrl),
      'latitude': cleanDouble(_latCtrl),
      'longitude': cleanDouble(_lngCtrl),

      'min_age': cleanInt(_minAgeCtrl),
      'max_age': cleanInt(_maxAgeCtrl),
      'preferred_gender': _preferredGender,

      'required_experience': cleanStr(_reqExperienceCtrl),
      'required_education': cleanStr(_reqEducationCtrl),
      'mandatory_skills': List<String>.from(_mandatorySkills),
      'preferred_languages': List<String>.from(_preferredLanguages),
      'immediate_joining': _immediateJoining,
      'local_candidate_preference': _localCandidatePreference,

      'job_summary': cleanStr(_jobSummaryCtrl),
      'responsibilities': cleanStr(_responsibilitiesCtrl),
      'required_skills_desc': cleanStr(_requiredSkillsDescCtrl),
      'benefits': cleanStr(_benefitsCtrl),
      'additional_information': cleanStr(_additionalInfoCtrl),

      'accept_applications_until':
          _acceptUntilDate != null ? _formatDate(_acceptUntilDate!) : null,
      'maximum_applications': cleanInt(_maxApplicationsCtrl),
      'screening_questions': List<String>.from(_screeningQuestions),

      'resume_mandatory': _resumeMandatory,
      'video_resume_required': _videoResumeRequired,
      'auto_response_message': cleanStr(_autoResponseCtrl),
      'application_visibility': _applicationVisibility,

      'is_featured': _featuredJob,
      'is_premium': _premiumJob,
      'is_walk_in_interview': _walkInInterview ? 1 : 0,
      'is_urgent_hiring': _urgentHiring,
      'top_search_placement': _topSearchPlacement,
      'homepage_placement': _homepagePlacement,
      'nearby_candidate_notification': _nearbyNotification,

      'status': asDraft
          ? 'draft'
          : (widget.jobToEdit != null
              ? (widget.jobToEdit!.status.isNotEmpty ? widget.jobToEdit!.status : 'published')
              : 'published'),
    };
  }

  Future<void> _submitJob({bool asDraft = false}) async {
    if (!_validateMandatoryFields()) {
      return;
    }

    var token = UserSession.token;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }

    if (token == null || token.isEmpty) {
      _showError('Please login to post a job');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = _buildPayload(asDraft: asDraft);
      final bool isEditing = widget.jobToEdit != null;

      if (isEditing) {
        final ok = await _jobPostController.updateJobPost(widget.jobToEdit!.id!, payload);

        if (!mounted) return;

        if (ok) {
          _showSuccessDialog(
            title: 'Job Updated Successfully!',
            message: 'Your changes have been saved.',
          );
        } else {
          final err = _jobPostController.errorMessage ??
              'Failed to update job. Please verify your inputs and try again.';
          _showError(err);
        }
      } else {
        final jobPostId = await _jobPostController.createJobPost(payload);

        if (!mounted) return;

        if (jobPostId != null) {
          _showSuccessDialog(
            title: asDraft ? 'Job Saved as Draft!' : 'Job Posted Successfully!',
            message: asDraft
                ? 'Your job listing has been saved as draft (ID #$jobPostId).'
                : 'Your job listing is now live and published with ID #$jobPostId.',
          );
        } else {
          final err = _jobPostController.errorMessage ??
              'Failed to post job. Please verify your inputs and try again.';
          if (err.toLowerCase().contains('company profile') || err.contains('100%')) {
            CompanyProfileGate.showIncompleteDialog(
              context,
              percentage: 0,
              message: err,
            );
          } else {
            _showError(err);
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      final err = e.toString().replaceFirst('Exception: ', '');
      if (err.toLowerCase().contains('company profile') || err.contains('100%')) {
        CompanyProfileGate.showIncompleteDialog(
          context,
          percentage: 0,
          message: err,
        );
      } else {
        _showError(err);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _goNext() {
    if (_currentStep == 0) {
      if (!_validateMandatoryFields()) return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _submitJob();
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

  // ─────────────────────────────────────────────
  // SHARED UI WIDGETS
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
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
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
    final uniqueItems = items.toSet().toList();
    final validValue = (value != null && uniqueItems.contains(value)) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          key: ValueKey('$label-$validValue'),
          initialValue: validValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary),
          decoration: _decoration(hint),
          items: uniqueItems
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
        color: AppColors.coralSoft.withValues(alpha: 0.5),
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
    TextEditingController inputCtrl, {
    List<String>? suggestions,
  }) {
    void addTag([String? manualVal]) {
      final val = (manualVal ?? inputCtrl.text).trim();
      if (val.isNotEmpty && !tags.contains(val)) {
        setState(() {
          tags.add(val);
          if (manualVal == null) inputCtrl.clear();
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
              onPressed: () => addTag(),
            ),
          ),
          onSubmitted: (_) => addTag(),
        ),
        if (suggestions != null && suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: suggestions.map((sug) {
              final alreadyAdded = tags.contains(sug);
              if (alreadyAdded) return const SizedBox.shrink();
              return ActionChip(
                label: Text('+ $sug',
                    style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                onPressed: () => addTag(sug),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
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
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                deleteIcon: const Icon(Icons.close,
                    size: 15, color: AppColors.primary),
                onDeleted: () => setState(() => tags.remove(tag)),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
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
  // STEP 1: BASIC INFO
  // ─────────────────────────────────────────────
  Widget _buildStep1BasicInfo() {
    return _stepCard([
      _textField('Job Title *', _jobTitleCtrl, 'e.g. Senior Software Engineer'),
      _gap(),
      _dropdown('Job Category *', _jobCategory, _categories,
          (v) => setState(() => _jobCategory = v),
          hint: 'Select category'),
      _gap(),
      _textField('Job Role', _jobRoleCtrl, 'e.g. Flutter Developer'),
      _gap(),
      _textField('Department', _departmentCtrl, 'e.g. Engineering'),
      _gap(),
      Row(
        children: [
          Expanded(
            child: _textField(
              'Vacancies *',
              _vacanciesCtrl,
              'e.g. 5',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _textField(
              'Remaining Vacancies',
              _remainingVacanciesCtrl,
              'e.g. 5',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
      _gap(),
      _dropdown('Employment Type', _employmentType, _employmentTypes,
          (v) => setState(() => _employmentType = v),
          hint: 'Select employment type'),
      _gap(),
      _dropdown('Job Level', _jobLevel, _jobLevels,
          (v) => setState(() => _jobLevel = v),
          hint: 'Select job level'),
    ]);
  }

  // ─────────────────────────────────────────────
  // STEP 2: SKILLS & EXPERIENCE
  // ─────────────────────────────────────────────
  Widget _buildStep2SkillsExperience() {
    return _stepCard([
      _textField('Experience Required', _experienceCtrl, 'e.g. 2-4 years'),
      _gap(),
      _dropdown('Qualification', _qualification, _qualifications,
          (v) => setState(() => _qualification = v),
          hint: 'Select qualification'),
      _gap(),
      _tagInput(
        'Skills',
        'Type a skill and press +',
        _skills,
        _skillInputCtrl,
        suggestions: _quickSkills,
      ),
      _gap(),
      _tagInput(
        'Language Requirements',
        'Type a language and press +',
        _languages,
        _languageInputCtrl,
        suggestions: _quickLanguages,
      ),
      _gap(),
      _tagInput(
        'Mandatory Skills',
        'Type a required skill and press +',
        _mandatorySkills,
        _mandatorySkillInputCtrl,
      ),
      _gap(),
      _tagInput(
        'Preferred Languages',
        'Type a preferred language and press +',
        _preferredLanguages,
        _preferredLangInputCtrl,
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // STEP 3: SALARY & TIMING
  // ─────────────────────────────────────────────
  Widget _buildStep3SalaryTiming() {
    return _stepCard([
      Row(
        children: [
          Expanded(
            child: _textField('Minimum Salary (₹)', _minSalaryCtrl, 'e.g. 25000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _textField('Maximum Salary (₹)', _maxSalaryCtrl, 'e.g. 45000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
        ],
      ),
      _gap(),
      _dropdown('Salary Frequency', _salaryFrequency, _salaryFrequencies,
          (v) => setState(() => _salaryFrequency = v)),
      _gap(),
      _switchTile('Salary is Negotiable', _negotiable,
          (v) => setState(() => _negotiable = v)),
      _switchTile('Hide Salary from Candidates', _hideSalary,
          (v) => setState(() => _hideSalary = v)),
      _sectionNote(
          'Hiding salary may reduce application volume based on candidate preferences.'),
      _gap(),
      _multiChipSelector('Working Days', _weekDays, _workingDays, (day) {
        setState(() {
          if (_workingDays.contains(day)) {
            _workingDays.remove(day);
          } else {
            _workingDays.add(day);
          }
        });
      }),
      _gap(),
      _dropdown('Shift Type', _shiftType, _shiftTypes,
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
                      context: context,
                      initialTime: _startTime ?? TimeOfDay.now(),
                    );
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startTime?.format(context) ?? 'Select time',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: _startTime == null
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                        const Icon(Icons.access_time,
                            size: 18, color: AppColors.textSecondary),
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
                _label('End Time'),
                InkWell(
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _endTime ?? TimeOfDay.now(),
                    );
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endTime?.format(context) ?? 'Select time',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: _endTime == null
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                        const Icon(Icons.access_time,
                            size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      _gap(),
      _dropdown('Weekly Off', _weeklyOff, _weeklyOffOptions,
          (v) => setState(() => _weeklyOff = v)),
      _gap(),
      _switchTile('Overtime Availability', _overtimeAvailable,
          (v) => setState(() => _overtimeAvailable = v)),
    ]);
  }

  // ─────────────────────────────────────────────
  // STEP 4: LOCATION
  // ─────────────────────────────────────────────
  Widget _buildStep4Location() {
    return _stepCard([
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ActionChip(
            avatar: const Icon(Icons.my_location, size: 15, color: AppColors.primary),
            label: const Text('Use Current Location',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
            onPressed: () {
              setState(() {
                _latCtrl.text = '19.0760';
                _lngCtrl.text = '72.8777';
                _cityCtrl.text = 'Mumbai';
                _stateCtrl.text = 'Maharashtra';
                _cityIdCtrl.text = '1';
                _stateIdCtrl.text = '1';
                _selectedCityId = 1;
                _selectedStateId = 1;
                _localityCtrl.text = 'Bandra Kurla Complex';
                _locationCtrl.text = 'BKC, Mumbai';
                _distanceKmCtrl.text = '2.5';
              });
            },
          ),
        ],
      ),
      _gap(),
      if (_apiStates.isNotEmpty) ...[
        _dropdown(
          'Select State (From DB)',
          _apiStates.any((s) => s['id']?.toString() == _stateIdCtrl.text)
              ? _apiStates.firstWhere((s) => s['id']?.toString() == _stateIdCtrl.text)['state_name']?.toString()
              : null,
          _apiStates.map((s) => s['state_name']?.toString() ?? '').where((s) => s.isNotEmpty).toList(),
          (selectedName) {
            final match = _apiStates.firstWhere(
              (s) => s['state_name']?.toString() == selectedName,
              orElse: () => {},
            );
            if (match.isNotEmpty) {
              setState(() {
                _stateCtrl.text = selectedName ?? '';
                _stateIdCtrl.text = match['id']?.toString() ?? '';
                _selectedStateId = int.tryParse(_stateIdCtrl.text);
                _autoFillLatLng(state: selectedName, city: _cityCtrl.text);
              });
            }
          },
          hint: 'Choose State',
        ),
        _gap(),
      ],
      if (_apiCities.isNotEmpty) ...[
        _dropdown(
          'Select City (From DB)',
          _apiCities.any((c) => c['id']?.toString() == _cityIdCtrl.text)
              ? _apiCities.firstWhere((c) => c['id']?.toString() == _cityIdCtrl.text)['city_name']?.toString()
              : null,
          _apiCities
              .where((c) => _selectedStateId == null || c['state_id'] == null || c['state_id'] == _selectedStateId)
              .map((c) => c['city_name']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList(),
          (selectedName) {
            final match = _apiCities.firstWhere(
              (c) => c['city_name']?.toString() == selectedName,
              orElse: () => {},
            );
            if (match.isNotEmpty) {
              setState(() {
                _cityCtrl.text = selectedName ?? '';
                _cityIdCtrl.text = match['id']?.toString() ?? '';
                _selectedCityId = int.tryParse(_cityIdCtrl.text);
                if (match['state_id'] != null) {
                  _selectedStateId = int.tryParse(match['state_id'].toString());
                  _stateIdCtrl.text = _selectedStateId?.toString() ?? _stateIdCtrl.text;
                  if (match['state_name'] != null && match['state_name'].toString().isNotEmpty) {
                    _stateCtrl.text = match['state_name'].toString();
                  }
                }
                _autoFillLatLng(state: _stateCtrl.text, city: selectedName);
              });
            }
          },
          hint: 'Choose City',
        ),
        _gap(),
      ],
      _dropdown('Select Saved Branch (Optional)', _savedBranch, _savedBranches,
          (v) => setState(() => _savedBranch = v)),
      _gap(),
      Row(
        children: [
          Expanded(child: _textField('Country', _countryCtrl, 'e.g. India')),
          const SizedBox(width: 12),
          Expanded(child: _textField('State Name', _stateCtrl, 'e.g. Maharashtra', onChanged: (val) {
            setState(() {
              _autoFillLatLng(state: val, city: _cityCtrl.text);
            });
          })),
        ],
      ),
      _gap(),
      Row(
        children: [
          Expanded(
            child: _textField('State ID', _stateIdCtrl, 'e.g. 1',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _textField('City ID', _cityIdCtrl, 'e.g. 101',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
        ],
      ),
      _gap(),
      Row(
        children: [
          Expanded(child: _textField('City Name', _cityCtrl, 'e.g. Mumbai', onChanged: (val) {
            setState(() {
              _autoFillLatLng(state: _stateCtrl.text, city: val);
            });
          })),
          const SizedBox(width: 12),
          Expanded(child: _textField('Locality', _localityCtrl, 'e.g. Andheri East')),
        ],
      ),
      _gap(),
      _textField('Location Summary', _locationCtrl, 'e.g. Andheri East, Mumbai'),
      _gap(),
      _textField('Full Address', _addressCtrl, 'Building, street, flat number',
          maxLines: 2),
      _gap(),
      _textField('Landmark', _landmarkCtrl, 'e.g. Opposite Metro Station'),
      _gap(),
      Row(
        children: [
          Expanded(
            child: _textField('Latitude', _latCtrl, 'e.g. 19.1136',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _textField('Longitude', _lngCtrl, 'e.g. 72.8697',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ),
        ],
      ),
      _gap(),
      Row(
        children: [
          Expanded(
            child: _textField('Distance (km)', _distanceKmCtrl, 'e.g. 3.2',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _textField('Branch ID (Optional)', _branchIdCtrl, 'e.g. 101',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
        ],
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // STEP 5: ELIGIBILITY
  // ─────────────────────────────────────────────
  Widget _buildStep5Eligibility() {
    return _stepCard([
      Row(
        children: [
          Expanded(
            child: _textField('Minimum Age', _minAgeCtrl, 'e.g. 18',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _textField('Maximum Age', _maxAgeCtrl, 'e.g. 45',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
        ],
      ),
      _gap(),
      _dropdown('Preferred Gender', _preferredGender, _genderOptions,
          (v) => setState(() => _preferredGender = v)),
      _gap(),
      _textField(
          'Required Experience Detail', _reqExperienceCtrl, 'e.g. Minimum 1 year in field sales'),
      _gap(),
      _textField('Required Education Detail', _reqEducationCtrl,
          'e.g. B.Tech, B.Sc or equivalent'),
      _gap(),
      _switchTile('Immediate Joining Preferred', _immediateJoining,
          (v) => setState(() => _immediateJoining = v)),
      _switchTile('Local Candidate Preference', _localCandidatePreference,
          (v) => setState(() => _localCandidatePreference = v)),
      _sectionNote(
          'Candidate eligibility filters must comply with applicable employment laws.'),
    ]);
  }

  // ─────────────────────────────────────────────
  // STEP 6: DESCRIPTION
  // ─────────────────────────────────────────────
  Widget _buildStep6Description() {
    return _stepCard([
      Row(
        children: [
          Expanded(
            flex: 3,
            child: _textField('Company Name', _companyNameCtrl, 'e.g. Acme Corp'),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: _textField('Initials', _companyInitialCtrl, 'e.g. AC'),
          ),
        ],
      ),
      _gap(),
      Row(
        children: [
          Expanded(
            child: _textField('Company Rating', _ratingCtrl, 'e.g. 4.5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _textField('Reviews Count', _reviewsCountCtrl, 'e.g. 15',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
        ],
      ),
      _gap(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Posted On Date'),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _postedOnDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (d != null) setState(() => _postedOnDate = d);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _postedOnDate == null
                        ? 'Select date'
                        : _formatDate(_postedOnDate!),
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                  const Icon(Icons.calendar_today,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
      _gap(),
      // AI Assistant Box
      InkWell(
        onTap: () => setState(() => _showAiAssistant = !_showAiAssistant),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
        _textField('Industry', _aiIndustryCtrl, 'e.g. Retail / IT'),
        _gap(12),
        _textField('Experience required', _aiExperienceCtrl, 'e.g. 2 years'),
        _gap(12),
        _textField('Main Responsibilities', _aiMainResponsibilitiesCtrl,
            'e.g. Building client relationships, closing sales', maxLines: 2),
        _gap(12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                final role = _jobTitleCtrl.text.isNotEmpty ? _jobTitleCtrl.text : 'Professional';
                final ind = _aiIndustryCtrl.text.isNotEmpty ? _aiIndustryCtrl.text : 'industry';
                _jobSummaryCtrl.text =
                    'We are looking for an ambitious $role to join our growing team in the $ind sector.';
                _descriptionCtrl.text =
                    'As a key member of the team, you will be responsible for driving results and contributing to project goals.';
                if (_aiMainResponsibilitiesCtrl.text.isNotEmpty) {
                  _responsibilitiesCtrl.text = _aiMainResponsibilitiesCtrl.text;
                }
                if (_skills.isNotEmpty) {
                  _requiredSkillsDescCtrl.text = _skills.join(', ');
                }
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
      _textField('Job Summary', _jobSummaryCtrl, 'Brief overview of the job',
          maxLines: 3),
      _gap(),
      _textField('Full Description', _descriptionCtrl, 'Detailed description of the role',
          maxLines: 3),
      _gap(),
      _textField('Responsibilities', _responsibilitiesCtrl,
          'Key duties and everyday tasks', maxLines: 3),
      _gap(),
      _textField('Required Skills Description', _requiredSkillsDescCtrl,
          'Details about skills expectations', maxLines: 2),
      _gap(),
      _textField('Benefits', _benefitsCtrl, 'e.g. PF, Health Insurance, Performance Bonus',
          maxLines: 2),
      _gap(),
      _textField('Additional Information', _additionalInfoCtrl,
          'Work culture, shift timings, perks, etc.', maxLines: 2),
    ]);
  }

  // ─────────────────────────────────────────────
  // STEP 7: APPLICATION SETTINGS
  // ─────────────────────────────────────────────
  Widget _buildStep7ApplicationSettings() {
    return _stepCard([
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Accept Applications Until'),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _acceptUntilDate ??
                    DateTime.now().add(const Duration(days: 30)),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _acceptUntilDate == null
                        ? 'Select closing date'
                        : _formatDate(_acceptUntilDate!),
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                  const Icon(Icons.calendar_today,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
      _gap(),
      _textField('Maximum Applications Limit', _maxApplicationsCtrl, 'e.g. 100',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
      _gap(),
      _tagInput('Screening Questions', 'Add screening question and tap +',
          _screeningQuestions, _screeningInputCtrl),
      _gap(),
      _switchTile('Resume Mandatory', _resumeMandatory,
          (v) => setState(() => _resumeMandatory = v),
          subtitle: 'Candidates must upload a resume to apply'),
      _switchTile('Video Resume Required', _videoResumeRequired,
          (v) => setState(() => _videoResumeRequired = v),
          subtitle: 'Require candidates to provide a 1-minute intro video'),
      _gap(),
      _textField('Auto-response Message', _autoResponseCtrl,
          'e.g. Thank you for your application! We will review it shortly.',
          maxLines: 2),
      _gap(),
      _dropdown('Application Visibility', _applicationVisibility,
          _visibilityOptions, (v) => setState(() => _applicationVisibility = v)),
    ]);
  }

  // ─────────────────────────────────────────────
  // STEP 8: VISIBILITY & PROMOTION
  // ─────────────────────────────────────────────
  Widget _buildStep8Promotion() {
    return _stepCard([
      _promoTile(
        'Featured Job',
        'Highlight this job with a prominent badge in listings',
        _featuredJob,
        (v) => setState(() => _featuredJob = v),
        Icons.star_outline,
      ),
      _promoTile(
        'Premium Jobs',
        'Highlight job in the exclusive Premium section',
        _premiumJob,
        (v) => setState(() => _premiumJob = v),
        Icons.workspace_premium_outlined,
      ),
      _promoTile(
        'Urgent Hiring Badge',
        'Mark this position as urgent to attract fast applicants',
        _urgentHiring,
        (v) => setState(() => _urgentHiring = v),
        Icons.flash_on,
      ),
      _promoTile(
        'Walk-in Interview',
        'Enable walk-in interview flag for direct candidates',
        _walkInInterview,
        (v) => setState(() => _walkInInterview = v),
        Icons.badge_outlined,
      ),
      _promoTile(
        'Top Search Placement',
        'Rank above standard jobs in keyword searches',
        _topSearchPlacement,
        (v) => setState(() => _topSearchPlacement = v),
        Icons.trending_up,
      ),
      _promoTile(
        'Homepage Placement',
        'Feature your job on the candidate home feed',
        _homepagePlacement,
        (v) => setState(() => _homepagePlacement = v),
        Icons.home_outlined,
      ),
      _promoTile(
        'Nearby Candidate Notification',
        'Push notifications to qualified job seekers within radius',
        _nearbyNotification,
        (v) => setState(() => _nearbyNotification = v),
        Icons.notifications_active_outlined,
      ),
      _sectionNote(
          'Promotions help increase your job reach. Check plan details before publishing.'),
    ]);
  }

  Widget _promoTile(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.border,
          width: value ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 20, color: value ? AppColors.primary : AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
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
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STEP 9: PREVIEW & SUBMIT
  // ─────────────────────────────────────────────
  Widget _buildStep9Preview() {
    final title = _jobTitleCtrl.text.trim();
    final category = _jobCategory ?? 'Not specified';
    final vacancies = _vacanciesCtrl.text.trim();
    final isMandatoryValid = title.isNotEmpty &&
        _jobCategory != null &&
        _jobCategory!.isNotEmpty &&
        vacancies.isNotEmpty;

    return _stepCard([
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMandatoryValid ? AppColors.mintSoft : AppColors.pinkSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isMandatoryValid ? Icons.check_circle : Icons.error_outline,
              size: 20,
              color: isMandatoryValid ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isMandatoryValid
                    ? 'All required fields are completed'
                    : 'Required fields missing: ${[
                        if (title.isEmpty) 'Title',
                        if (_jobCategory == null || _jobCategory!.isEmpty) 'Category',
                        if (vacancies.isEmpty) 'Vacancies',
                      ].join(', ')}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isMandatoryValid ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
      _gap(12),
      _previewCard('1. Basic Details', [
        'Title: ${title.isEmpty ? "-" : title}',
        'Category: $category',
        'Role: ${_jobRoleCtrl.text.isEmpty ? "-" : _jobRoleCtrl.text}',
        'Department: ${_departmentCtrl.text.isEmpty ? "-" : _departmentCtrl.text}',
        'Vacancies: ${vacancies.isEmpty ? "-" : vacancies}',
        'Remaining Vacancies: ${_remainingVacanciesCtrl.text.isEmpty ? "-" : _remainingVacanciesCtrl.text}',
        'Type: ${_employmentType ?? "-"}',
        'Level: ${_jobLevel ?? "-"}',
      ]),
      _gap(10),
      _previewCard('2. Skills & Qualifications', [
        'Experience: ${_experienceCtrl.text.isEmpty ? "-" : _experienceCtrl.text}',
        'Qualification: ${_qualification ?? "-"}',
        'Skills: ${_skills.isEmpty ? "None" : _skills.join(", ")}',
        'Languages: ${_languages.isEmpty ? "None" : _languages.join(", ")}',
        'Mandatory Skills: ${_mandatorySkills.isEmpty ? "None" : _mandatorySkills.join(", ")}',
        'Preferred Languages: ${_preferredLanguages.isEmpty ? "None" : _preferredLanguages.join(", ")}',
      ]),
      _gap(10),
      _previewCard('3. Salary & Timing', [
        'Salary: ₹${_minSalaryCtrl.text.isEmpty ? "0" : _minSalaryCtrl.text} - ₹${_maxSalaryCtrl.text.isEmpty ? "0" : _maxSalaryCtrl.text} (${_salaryFrequency ?? "Monthly"})',
        'Negotiable: ${_negotiable ? "Yes" : "No"}',
        'Hide Salary: ${_hideSalary ? "Yes" : "No"}',
        'Working Days: ${_workingDays.isEmpty ? "None" : _workingDays.join(", ")}',
        'Shift: ${_shiftType ?? "-"}',
        'Timings: ${_startTime?.format(context) ?? "-"} to ${_endTime?.format(context) ?? "-"}',
        'Weekly Off: ${_weeklyOff ?? "-"}',
        'Overtime: ${_overtimeAvailable ? "Available" : "No"}',
      ]),
      _gap(10),
      _previewCard('4. Location Details', [
        'Location: ${_locationCtrl.text.isEmpty ? "-" : _locationCtrl.text}',
        'City: ${_cityCtrl.text.isEmpty ? "-" : _cityCtrl.text}, ${_stateCtrl.text.isEmpty ? "-" : _stateCtrl.text}',
        'Country: ${_countryCtrl.text.isEmpty ? "India" : _countryCtrl.text}',
        'Address: ${_addressCtrl.text.isEmpty ? "-" : _addressCtrl.text}',
        'Landmark: ${_landmarkCtrl.text.isEmpty ? "-" : _landmarkCtrl.text}',
        'Coordinates: ${_latCtrl.text.isEmpty ? "-" : _latCtrl.text}, ${_lngCtrl.text.isEmpty ? "-" : _lngCtrl.text}',
      ]),
      _gap(10),
      _previewCard('5. Eligibility Criteria', [
        'Age Range: ${_minAgeCtrl.text.isEmpty ? "18" : _minAgeCtrl.text} - ${_maxAgeCtrl.text.isEmpty ? "Any" : _maxAgeCtrl.text} years',
        'Gender: ${_preferredGender ?? "Any"}',
        'Immediate Joining: ${_immediateJoining ? "Yes" : "No"}',
        'Local Candidate: ${_localCandidatePreference ? "Preferred" : "No preference"}',
      ]),
      _gap(10),
      _previewCard('6. Description & Company', [
        'Company: ${_companyNameCtrl.text.isEmpty ? "-" : _companyNameCtrl.text}',
        'Summary: ${_jobSummaryCtrl.text.isEmpty ? "-" : _jobSummaryCtrl.text}',
        'Posted On: ${_postedOnDate != null ? _formatDate(_postedOnDate!) : "-"}',
      ]),
      _gap(10),
      _previewCard('7. Application Settings', [
        'Accept Until: ${_acceptUntilDate != null ? _formatDate(_acceptUntilDate!) : "-"}',
        'Max Applications: ${_maxApplicationsCtrl.text.isEmpty ? "Unlimited" : _maxApplicationsCtrl.text}',
        'Screening Questions: ${_screeningQuestions.isEmpty ? "None" : "${_screeningQuestions.length} questions"}',
        'Resume Required: ${_resumeMandatory ? "Yes" : "No"}',
        'Video Resume: ${_videoResumeRequired ? "Yes" : "No"}',
        'Visibility: ${_applicationVisibility ?? "Public"}',
      ]),
      _gap(10),
      _previewCard('8. Promotion Features', [
        'Featured: ${_featuredJob ? "Yes" : "No"}',
        'Walk-in Interview: ${_walkInInterview ? "Yes" : "No"}',
        'Urgent Hiring: ${_urgentHiring ? "Yes" : "No"}',
        'Top Placement: ${_topSearchPlacement ? "Yes" : "No"}',
        'Homepage: ${_homepagePlacement ? "Yes" : "No"}',
        'Nearby Alerts: ${_nearbyNotification ? "Yes" : "No"}',
      ]),
      _gap(20),
      if (_isSubmitting)
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        )
      else ...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(
              widget.jobToEdit != null ? Icons.check_circle : Icons.rocket_launch,
              size: 20,
              color: AppColors.buttonText,
            ),
            label: Text(
              widget.jobToEdit != null ? 'Update Job' : 'Post & Publish Job',
              style: const TextStyle(
                color: AppColors.buttonText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => _submitJob(asDraft: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        if (widget.jobToEdit == null) ...[
          _gap(10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.bookmark_border, size: 18, color: AppColors.primary),
              label: const Text(
                'Save as Draft',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _submitJob(asDraft: true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
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
      _buildStep1BasicInfo(),
      _buildStep2SkillsExperience(),
      _buildStep3SalaryTiming(),
      _buildStep4Location(),
      _buildStep5Eligibility(),
      _buildStep6Description(),
      _buildStep7ApplicationSettings(),
      _buildStep8Promotion(),
      _buildStep9Preview(),
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
        title: Text(
          widget.jobToEdit != null ? "Edit Job" : "Post New Jobs",
          style: const TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Progress Indicator
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
            // Step Content PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: steps,
              ),
            ),
            // Bottom Action Navigation Bar
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
