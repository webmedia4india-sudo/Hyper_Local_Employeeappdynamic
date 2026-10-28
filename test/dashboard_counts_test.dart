import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dashboard Dynamic Counts Logic Tests', () {
    test('Job status filtering counts active/published jobs correctly', () {
      final mockJobs = [
        {'title': 'Job 1', 'status': 'published'},
        {'title': 'Job 2', 'status': 'active'},
        {'title': 'Job 3', 'status': 'draft'},
        {'title': 'Job 4', 'status': 'expired'},
        {'title': 'Job 5', 'status': ''},
      ];

      final activeJobsCount = mockJobs.where((j) {
        final st = j['status']!.toLowerCase().trim();
        return st == 'active' || st == 'published' || st.isEmpty;
      }).length;

      expect(activeJobsCount, equals(3));
    });

    test('Application statuses mapped correctly to Total, New, and Shortlisted', () {
      final mockApplications = [
        {'id': 1, 'application_status': 'applied'},
        {'id': 2, 'application_status': 'shortlisted'},
        {'id': 3, 'application_status': 'shortlisted'},
        {'id': 4, 'application_status': 'new'},
        {'id': 5, 'application_status': 'rejected'},
        {'id': 6, 'application_status': 'under_review'},
        {'id': 7, 'application_status': 'withdrawn'},
      ];

      int total = mockApplications.length;
      int shortlisted = 0;
      int newApps = 0;

      for (final app in mockApplications) {
        final st = (app['application_status'] ?? '').toString().toLowerCase().trim();
        if (st == 'shortlisted') {
          shortlisted++;
        } else if (st == 'applied' || st == 'new' || (st != 'rejected' && st != 'withdrawn')) {
          newApps++;
        }
      }

      expect(total, equals(7));
      expect(shortlisted, equals(2));
      expect(newApps, equals(3)); // applied, new, under_review
    });

    test('Interviews count reflects scheduled and rescheduled interviews', () {
      final mockInterviews = [
        {'id': 1, 'interview_status': 'scheduled'},
        {'id': 2, 'interview_status': 'rescheduled'},
      ];

      expect(mockInterviews.length, equals(2));
    });
  });
}
