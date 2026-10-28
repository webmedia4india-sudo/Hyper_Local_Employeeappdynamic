import 'dart:convert';

class CandidateCardModel {
  final int applicationId;
  final int? userId;
  final int? jobPostId;
  final String name;
  final String address;
  final String? profilePhoto;
  final String? appliedFor;
  final String employmentType;
  final dynamic educationRaw;
  final String education;
  final List<String> skills;
  final String? resumeFile;
  final bool hasResume;
  final double matchPercentage;
  final double experienceYears;
  final int noticePeriodDays;
  final num expectedCtcMin;
  final num expectedCtcMax;
  final String? applicationStatus;

  CandidateCardModel({
    required this.applicationId,
    this.userId,
    this.jobPostId,
    required this.name,
    required this.address,
    this.profilePhoto,
    this.appliedFor,
    required this.employmentType,
    this.educationRaw,
    required this.education,
    required this.skills,
    this.resumeFile,
    required this.hasResume,
    required this.matchPercentage,
    required this.experienceYears,
    required this.noticePeriodDays,
    required this.expectedCtcMin,
    required this.expectedCtcMax,
    this.applicationStatus,
  });

  factory CandidateCardModel.fromJson(Map<String, dynamic> json) {
    final rawEducation = json['education'];
    return CandidateCardModel(
      applicationId: _toInt(json['application_id'] ?? json['id']),
      userId: json['user_id'] != null ? _toInt(json['user_id']) : null,
      jobPostId: json['job_post_id'] != null ? _toInt(json['job_post_id']) : null,
      name: json['name']?.toString() ?? 'Applicant',
      address: json['address']?.toString() ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      appliedFor: json['applied_for']?.toString(),
      employmentType: json['employment_type']?.toString() ?? 'Full-time',
      educationRaw: rawEducation,
      education: _parseEducation(rawEducation),
      skills: _parseSkills(json['skills']),
      resumeFile: json['resume_file']?.toString(),
      hasResume: _toBool(json['has_resume']) ||
          (json['resume_file'] != null && json['resume_file'].toString().trim().isNotEmpty),
      matchPercentage: _toDouble(json['match_percentage'] ?? json['matchPercent']),
      experienceYears: _toDouble(json['experience_years'] ?? json['experience']),
      noticePeriodDays: _toInt(json['notice_period_days'] ?? json['noticePeriod']),
      expectedCtcMin: _toNum(json['expected_ctc_min'] ?? json['ctcMin']),
      expectedCtcMax: _toNum(json['expected_ctc_max'] ?? json['ctcMax']),
      applicationStatus: json['application_status']?.toString(),
    );
  }

  // --- Getters ---

  String get experienceText {
    if (experienceYears == 0) return '';
    if (experienceYears == 1) return '1 Year';
    if (experienceYears % 1 == 0) {
      return '${experienceYears.toInt()} Years';
    }
    return '$experienceYears Years';
  }

  String get noticeText {
    if (noticePeriodDays == 0) return '';
    return '$noticePeriodDays Days';
  }

  String get ctcText {
    if (expectedCtcMin == 0 && expectedCtcMax == 0) {
      return 'Not specified';
    }

    num minLpa = expectedCtcMin;
    num maxLpa = expectedCtcMax;

    if (minLpa > 1000) minLpa = minLpa / 100000;
    if (maxLpa > 1000) maxLpa = maxLpa / 100000;

    String formatVal(num val) {
      if (val % 1 == 0) return val.toInt().toString();
      return val.toStringAsFixed(1);
    }

    if (minLpa > 0 && maxLpa > 0) {
      return '₹${formatVal(minLpa)} - ${formatVal(maxLpa)} LPA';
    } else if (minLpa > 0) {
      return '₹${formatVal(minLpa)} LPA';
    } else {
      return '₹${formatVal(maxLpa)} LPA';
    }
  }

  // --- Parsing Helpers ---

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      final p = double.tryParse(val.trim());
      return p?.toInt() ?? 0;
    }
    return 0;
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val.trim()) ?? 0.0;
    }
    return 0.0;
  }

  static num _toNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    if (val is String) {
      return num.tryParse(val.trim()) ?? 0;
    }
    return 0;
  }

  static bool _toBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final lower = val.trim().toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  static List<String> _parseSkills(dynamic val) {
    if (val == null) return [];
    if (val is List) {
      return val.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    if (val is String) {
      final trimmed = val.trim();
      if (trimmed.isEmpty) return [];
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
        }
      } catch (_) {}
      return trimmed.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  static String _parseEducation(dynamic val) {
    if (val == null) return 'Not specified';

    dynamic target = val;
    if (val is String) {
      final trimmed = val.trim();
      if (trimmed.isEmpty) return 'Not specified';
      try {
        target = jsonDecode(trimmed);
      } catch (_) {
        return trimmed;
      }
    }

    if (target is Map) {
      final degree = (target['degree'] ?? target['course'] ?? target['title'] ?? target['qualification'] ?? '').toString().trim();
      final institute = (target['institute'] ?? target['university'] ?? target['college'] ?? target['school'] ?? '').toString().trim();
      if (degree.isNotEmpty && institute.isNotEmpty) {
        return '$degree - $institute';
      } else if (degree.isNotEmpty) {
        return degree;
      } else if (institute.isNotEmpty) {
        return institute;
      }
    } else if (target is List && target.isNotEmpty) {
      return _parseEducation(target.first);
    }

    return target?.toString() ?? 'Not specified';
  }
}
