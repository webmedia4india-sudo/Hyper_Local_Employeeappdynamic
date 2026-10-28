class JobPostModel {
  int? id;
  int? employerId;

  // Basic Info & General
  String? companyName;
  String? companyInitial;
  String? location;
  double? distanceKm;
  double? rating;
  int? reviewsCount;
  String? postedOn;
  String? description;

  String? jobTitle;
  String? jobCategory;
  String? jobRole;
  String? department;
  int? numberOfVacancies;
  int? remainingVacancies;

  // Employment & Skills
  String? employmentType;
  String? jobLevel;
  String? experienceRequired;
  String? qualification;
  List<String> skills;
  List<String> languageRequirements;

  // Salary & Timing
  int? minSalary;
  int? maxSalary;
  String? salaryFrequency;
  bool isNegotiable;
  bool hideSalary;

  List<String> workingDays;
  String? shiftType;
  String? startTime;
  String? endTime;
  String? weeklyOff;
  bool overtimeAvailability;

  // Location
  int? branchId;
  String country;
  int? stateId;
  int? cityId;
  String? state;
  String? city;
  String? locality;
  String? fullAddress;
  String? landmark;
  double? latitude;
  double? longitude;

  // Eligibility
  int? minAge;
  int? maxAge;
  String? preferredGender;
  String? requiredExperience;
  String? requiredEducation;
  List<String> mandatorySkills;
  List<String> preferredLanguages;
  bool immediateJoining;
  bool localCandidatePreference;

  // Description
  String? jobSummary;
  String? responsibilities;
  String? requiredSkillsDesc;
  String? benefits;
  String? additionalInformation;

  // Application Settings
  String? acceptApplicationsUntil;
  int? maximumApplications;
  List<String> screeningQuestions;
  bool resumeMandatory;
  bool videoResumeRequired;
  String? autoResponseMessage;
  String? applicationVisibility;

  // Visibility / Promotion
  bool isFeatured;
  bool isPremium;
  bool isWalkInInterview;
  bool isUrgentHiring;
  bool topSearchPlacement;
  bool homepagePlacement;
  bool nearbyCandidateNotification;

  // Backend generated/managed fields (parsed from GET, not sent in create POST)
  String status;
  String? createdAt;
  String? updatedAt;

  JobPostModel({
    this.id,
    this.employerId,
    this.companyName,
    this.companyInitial,
    this.location,
    this.distanceKm,
    this.rating,
    this.reviewsCount,
    this.postedOn,
    this.description,
    this.jobTitle,
    this.jobCategory,
    this.jobRole,
    this.department,
    this.numberOfVacancies,
    this.remainingVacancies,
    this.employmentType,
    this.jobLevel,
    this.experienceRequired,
    this.qualification,
    this.skills = const [],
    this.languageRequirements = const [],
    this.minSalary,
    this.maxSalary,
    this.salaryFrequency,
    this.isNegotiable = false,
    this.hideSalary = false,
    this.workingDays = const [],
    this.shiftType,
    this.startTime,
    this.endTime,
    this.weeklyOff,
    this.overtimeAvailability = false,
    this.branchId,
    this.country = 'India',
    this.stateId,
    this.cityId,
    this.state,
    this.city,
    this.locality,
    this.fullAddress,
    this.landmark,
    this.latitude,
    this.longitude,
    this.minAge,
    this.maxAge,
    this.preferredGender,
    this.requiredExperience,
    this.requiredEducation,
    this.mandatorySkills = const [],
    this.preferredLanguages = const [],
    this.immediateJoining = false,
    this.localCandidatePreference = false,
    this.jobSummary,
    this.responsibilities,
    this.requiredSkillsDesc,
    this.benefits,
    this.additionalInformation,
    this.acceptApplicationsUntil,
    this.maximumApplications,
    this.screeningQuestions = const [],
    this.resumeMandatory = true,
    this.videoResumeRequired = false,
    this.autoResponseMessage,
    this.applicationVisibility,
    this.isFeatured = false,
    this.isPremium = false,
    this.isWalkInInterview = false,
    this.isUrgentHiring = false,
    this.topSearchPlacement = false,
    this.homepagePlacement = false,
    this.nearbyCandidateNotification = false,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
  });

  // ─────────────────────────────────────────────
  // fromJson — backend GET response parsing
  // ─────────────────────────────────────────────
  factory JobPostModel.fromJson(Map<String, dynamic> json) {
    List<String> toStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    double? toDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    int? toInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    bool toBool(dynamic value) {
      return value == 1 || value == true || value == '1' || value == 'true';
    }

    return JobPostModel(
      id: toInt(json['id']),
      employerId: toInt(json['employer_id']),

      companyName: json['company_name'],
      companyInitial: json['company_initial'],
      location: json['location'],
      distanceKm: toDouble(json['distance_km']),
      rating: toDouble(json['rating']),
      reviewsCount: toInt(json['reviews_count']),
      postedOn: json['posted_on'],
      description: json['description'],

      jobTitle: json['job_title'],
      jobCategory: json['job_category'],
      jobRole: json['job_role'],
      department: json['department'],
      numberOfVacancies: toInt(json['number_of_vacancies']),
      remainingVacancies: toInt(json['remaining_vacancies']),

      employmentType: json['employment_type'],
      jobLevel: json['job_level'],
      experienceRequired: json['experience_required'],
      qualification: json['qualification'],
      skills: toStringList(json['skills']),
      languageRequirements: toStringList(json['language_requirements']),

      minSalary: toInt(json['min_salary']),
      maxSalary: toInt(json['max_salary']),
      salaryFrequency: json['salary_frequency'],
      isNegotiable: toBool(json['is_negotiable']),
      hideSalary: toBool(json['hide_salary']),

      workingDays: toStringList(json['working_days']),
      shiftType: json['shift_type'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      weeklyOff: json['weekly_off'],
      overtimeAvailability: toBool(json['overtime_availability']),

      branchId: toInt(json['branch_id']),
      country: json['country'] ?? 'India',
      stateId: toInt(json['state_id'] ?? json['stateId']),
      cityId: toInt(json['city_id'] ?? json['cityId']),
      state: json['state_name'] ?? json['state']?.toString(),
      city: json['city_name'] ?? json['city']?.toString(),
      locality: json['locality'],
      fullAddress: json['full_address'],
      landmark: json['landmark'],
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),

      minAge: toInt(json['min_age']),
      maxAge: toInt(json['max_age']),
      preferredGender: json['preferred_gender'],
      requiredExperience: json['required_experience'],
      requiredEducation: json['required_education'],
      mandatorySkills: toStringList(json['mandatory_skills']),
      preferredLanguages: toStringList(json['preferred_languages']),
      immediateJoining: toBool(json['immediate_joining']),
      localCandidatePreference: toBool(json['local_candidate_preference']),

      jobSummary: json['job_summary'],
      responsibilities: json['responsibilities'],
      requiredSkillsDesc: json['required_skills_desc'],
      benefits: json['benefits'],
      additionalInformation: json['additional_information'],

      acceptApplicationsUntil: json['accept_applications_until'],
      maximumApplications: toInt(json['maximum_applications']),
      screeningQuestions: toStringList(json['screening_questions']),
      resumeMandatory: toBool(json['resume_mandatory']),
      videoResumeRequired: toBool(json['video_resume_required']),
      autoResponseMessage: json['auto_response_message'],
      applicationVisibility: json['application_visibility'],

      isFeatured: toBool(json['is_featured']),
      isPremium: toBool(json['is_premium']),
      isWalkInInterview: toBool(json['is_walk_in_interview'] ?? json['isWalkInInterview'] ?? json['isWalkIn']),
      isUrgentHiring: toBool(json['is_urgent_hiring']),
      topSearchPlacement: toBool(json['top_search_placement']),
      homepagePlacement: toBool(json['homepage_placement']),
      nearbyCandidateNotification: toBool(json['nearby_candidate_notification']),

      status: json['status'] ?? 'draft',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  // ─────────────────────────────────────────────
  // toFullJson — POST /api/jobpost/ payload
  // Note: Do NOT include employer_id, status, id, created_at, updated_at
  // ─────────────────────────────────────────────
  Map<String, dynamic> toFullJson() {
    return {
      'company_name': companyName,
      'company_initial': companyInitial,
      'location': location,
      'distance_km': distanceKm,
      'rating': rating,
      'reviews_count': reviewsCount,
      'posted_on': postedOn,
      'description': description,

      'job_title': jobTitle,
      'job_category': jobCategory,
      'job_role': jobRole,
      'department': department,
      'number_of_vacancies': numberOfVacancies,
      'remaining_vacancies': remainingVacancies,

      'employment_type': employmentType,
      'job_level': jobLevel,
      'experience_required': experienceRequired,
      'qualification': qualification,
      'skills': skills,
      'language_requirements': languageRequirements,

      'min_salary': minSalary,
      'max_salary': maxSalary,
      'salary_frequency': salaryFrequency,
      'is_negotiable': isNegotiable,
      'hide_salary': hideSalary,

      'working_days': workingDays,
      'shift_type': shiftType,
      'start_time': startTime,
      'end_time': endTime,
      'weekly_off': weeklyOff,
      'overtime_availability': overtimeAvailability,

      'branch_id': branchId,

      'country': country,
      'state_id': stateId ?? _parseToInt(state),
      'city_id': cityId ?? _parseToInt(city),
      'state': state,
      'city': city,
      'locality': locality,
      'full_address': fullAddress,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,

      'min_age': minAge,
      'max_age': maxAge,
      'preferred_gender': preferredGender,

      'required_experience': requiredExperience,
      'required_education': requiredEducation,
      'mandatory_skills': mandatorySkills,
      'preferred_languages': preferredLanguages,
      'immediate_joining': immediateJoining,
      'local_candidate_preference': localCandidatePreference,

      'job_summary': jobSummary,
      'responsibilities': responsibilities,
      'required_skills_desc': requiredSkillsDesc,
      'benefits': benefits,
      'additional_information': additionalInformation,

      'accept_applications_until': acceptApplicationsUntil,
      'maximum_applications': maximumApplications,
      'screening_questions': screeningQuestions,

      'resume_mandatory': resumeMandatory,
      'video_resume_required': videoResumeRequired,
      'auto_response_message': autoResponseMessage,
      'application_visibility': applicationVisibility,

      'is_featured': isFeatured,
      'is_premium': isPremium,
      'is_walk_in_interview': isWalkInInterview ? 1 : 0,
      'is_urgent_hiring': isUrgentHiring,
      'top_search_placement': topSearchPlacement,
      'homepage_placement': homepagePlacement,
      'nearby_candidate_notification': nearbyCandidateNotification,

      'status': status.isNotEmpty ? status : 'published',
    };
  }
}
