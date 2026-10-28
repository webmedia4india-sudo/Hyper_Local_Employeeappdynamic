import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_local_employee/models/job_post_model.dart';

void main() {
  test('JobPostModel toFullJson contains all required fields accurately', () {
    final model = JobPostModel(
      jobTitle: 'Field Sales Executive',
      jobCategory: 'Retail / Sales',
      jobRole: 'Sales Rep',
      department: 'Marketing',
      numberOfVacancies: 5,
      employmentType: 'Full-time',
      jobLevel: 'Entry Level',
      experienceRequired: '1-2 years',
      qualification: 'Graduate',
      skills: ['Sales', 'Negotiation'],
      languageRequirements: ['English', 'Marathi', 'Hindi'],
      minSalary: 15000,
      maxSalary: 25000,
      salaryFrequency: 'Monthly',
      isNegotiable: true,
      hideSalary: false,
      workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      shiftType: 'Day shift',
      startTime: '09:00:00',
      endTime: '18:00:00',
      weeklyOff: 'Sun',
      overtimeAvailability: true,
      branchId: 1,
      country: 'India',
      state: 'Maharashtra',
      city: 'Nagpur',
      locality: 'Dharampeth',
      fullAddress: 'Plot 10, West High Court Road',
      landmark: 'Near Coffee House',
      latitude: 21.1458,
      longitude: 79.0882,
      minAge: 20,
      maxAge: 35,
      preferredGender: 'Any',
      requiredExperience: '1 year',
      requiredEducation: 'Any Graduate',
      mandatorySkills: ['Communication'],
      preferredLanguages: ['Hindi', 'Marathi'],
      immediateJoining: true,
      localCandidatePreference: true,
      jobSummary: 'Looking for an active sales professional.',
      responsibilities: 'Meet retail clients and take orders.',
      requiredSkillsDesc: 'Basic sales & communication skills.',
      benefits: 'PF, ESI, Travel Allowance',
      additionalInformation: 'Two wheeler required.',
      acceptApplicationsUntil: '2026-10-31',
      maximumApplications: 100,
      screeningQuestions: ['Do you have a bike?'],
      resumeMandatory: true,
      videoResumeRequired: false,
      autoResponseMessage: 'Thank you for applying!',
      applicationVisibility: 'Public',
      isFeatured: true,
      isUrgentHiring: true,
      topSearchPlacement: false,
      homepagePlacement: false,
      nearbyCandidateNotification: true,
      status: 'active',
    );

    final json = model.toFullJson();

    expect(json['job_title'], equals('Field Sales Executive'));
    expect(json['job_category'], equals('Retail / Sales'));
    expect(json['job_role'], equals('Sales Rep'));
    expect(json['department'], equals('Marketing'));
    expect(json['number_of_vacancies'], equals(5));
    expect(json['employment_type'], equals('Full-time'));
    expect(json['job_level'], equals('Entry Level'));
    expect(json['experience_required'], equals('1-2 years'));
    expect(json['qualification'], equals('Graduate'));
    expect(json['skills'], equals(['Sales', 'Negotiation']));
    expect(json['language_requirements'], equals(['English', 'Marathi', 'Hindi']));
    expect(json['min_salary'], equals(15000));
    expect(json['max_salary'], equals(25000));
    expect(json['salary_frequency'], equals('Monthly'));
    expect(json['is_negotiable'], isTrue);
    expect(json['hide_salary'], isFalse);
    expect(json['working_days'], equals(['Mon', 'Tue', 'Wed', 'Thu', 'Fri']));
    expect(json['shift_type'], equals('Day shift'));
    expect(json['start_time'], equals('09:00:00'));
    expect(json['end_time'], equals('18:00:00'));
    expect(json['weekly_off'], equals('Sun'));
    expect(json['overtime_availability'], isTrue);
    expect(json['branch_id'], equals(1));
    expect(json['country'], equals('India'));
    expect(json['state'], equals('Maharashtra'));
    expect(json['city'], equals('Nagpur'));
    expect(json['locality'], equals('Dharampeth'));
    expect(json['full_address'], equals('Plot 10, West High Court Road'));
    expect(json['landmark'], equals('Near Coffee House'));
    expect(json['latitude'], equals(21.1458));
    expect(json['longitude'], equals(79.0882));
    expect(json['min_age'], equals(20));
    expect(json['max_age'], equals(35));
    expect(json['preferred_gender'], equals('Any'));
    expect(json['required_experience'], equals('1 year'));
    expect(json['required_education'], equals('Any Graduate'));
    expect(json['mandatory_skills'], equals(['Communication']));
    expect(json['preferred_languages'], equals(['Hindi', 'Marathi']));
    expect(json['immediate_joining'], isTrue);
    expect(json['local_candidate_preference'], isTrue);
    expect(json['job_summary'], equals('Looking for an active sales professional.'));
    expect(json['responsibilities'], equals('Meet retail clients and take orders.'));
    expect(json['required_skills_desc'], equals('Basic sales & communication skills.'));
    expect(json['benefits'], equals('PF, ESI, Travel Allowance'));
    expect(json['additional_information'], equals('Two wheeler required.'));
    expect(json['accept_applications_until'], equals('2026-10-31'));
    expect(json['maximum_applications'], equals(100));
    expect(json['screening_questions'], equals(['Do you have a bike?']));
    expect(json['resume_mandatory'], isTrue);
    expect(json['video_resume_required'], isFalse);
    expect(json['auto_response_message'], equals('Thank you for applying!'));
    expect(json['application_visibility'], equals('Public'));
    expect(json['is_featured'], isTrue);
    expect(json['is_urgent_hiring'], isTrue);
    expect(json['top_search_placement'], isFalse);
    expect(json['homepage_placement'], isFalse);
    expect(json['nearby_candidate_notification'], isTrue);
    expect(json['status'], equals('active'));
  });
}
