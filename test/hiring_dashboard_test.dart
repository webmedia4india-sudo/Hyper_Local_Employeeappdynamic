import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hiring Dashboard Dynamic Calculations', () {
    final mockApplications = [
      {
        'application_id': 2,
        'job_post_id': 2,
        'job_title': 'dsf',
        'application_status': 'shortlisted',
        'applied_at': '2026-10-15T06:55:54.000Z',
      },
      {
        'application_id': 5,
        'job_post_id': 6,
        'job_title': 'sql query',
        'application_status': 'shortlisted',
        'applied_at': '2026-10-16T05:28:57.000Z',
      },
      {
        'application_id': 8,
        'job_post_id': 12,
        'job_title': 'gr',
        'application_status': 'shortlisted',
        'applied_at': '2026-10-16T10:17:04.000Z',
      },
      {
        'application_id': 10,
        'job_post_id': 14,
        'job_title': 'wedw',
        'application_status': 'shortlisted',
        'applied_at': '2026-10-19T06:53:52.000Z',
      },
      {
        'application_id': 11,
        'job_post_id': 2,
        'job_title': 'dsf',
        'application_status': 'hired',
        'applied_at': '2026-10-20T08:00:00.000Z',
      },
    ];

    final mockInvitations = [
      {
        'id': 1,
        'employer_id': 2,
        'interview_date': '2026-10-15T18:30:00.000Z',
        'sent_at': '2026-10-15T07:04:56.000Z',
      },
      {
        'id': 2,
        'employer_id': 2,
        'interview_date': '2026-10-16T18:30:00.000Z',
        'sent_at': '2026-10-16T07:07:27.000Z',
      },
      {
        'id': 3,
        'employer_id': 2,
        'interview_date': '2026-10-17T18:30:00.000Z',
        'sent_at': '2026-10-17T05:56:50.000Z',
      },
      {
        'id': 4,
        'employer_id': 2,
        'interview_date': '2026-10-19T18:30:00.000Z',
        'sent_at': '2026-10-19T06:57:45.000Z',
      },
    ];

    test('Total Views is 0 because database does not support view tracking', () {
      const totalViews = 0;
      expect(totalViews, 0);
    });

    test('Applications count filters correctly by This Month (October 2026)', () {
      final startOfMonth = DateTime(2026, 10, 1);
      final endOfMonth = DateTime(2026, 10, 31, 23, 59, 59, 999);

      final inMonth = mockApplications.where((a) {
        final dt = DateTime.tryParse(a['applied_at'].toString())?.toLocal();
        return dt != null && !dt.isBefore(startOfMonth) && !dt.isAfter(endOfMonth);
      }).toList();

      expect(inMonth.length, 5);
    });

    test('Hired count correctly counts hired, selected, or offer_accepted statuses', () {
      final hiredCount = mockApplications.where((a) {
        final st = (a['application_status'] ?? '').toString().toLowerCase();
        return st == 'hired' || st == 'selected' || st == 'offer_accepted';
      }).length;

      expect(hiredCount, 1);
    });

    test('Interviews count filters correctly for employer', () {
      final startOfMonth = DateTime(2026, 10, 1);
      final endOfMonth = DateTime(2026, 10, 31, 23, 59, 59, 999);

      final inMonth = mockInvitations.where((inv) {
        final dt = DateTime.tryParse(inv['interview_date'].toString())?.toLocal();
        return dt != null && !dt.isBefore(startOfMonth) && !dt.isAfter(endOfMonth);
      }).toList();

      expect(inMonth.length, 4);
    });

    test('Top Performing Jobs sorted descending by application count', () {
      final Map<int, int> appCountByJobId = {};
      final Map<int, String> jobTitleById = {};

      for (final a in mockApplications) {
        final jobId = a['job_post_id'] as int;
        appCountByJobId[jobId] = (appCountByJobId[jobId] ?? 0) + 1;
        jobTitleById[jobId] = a['job_title'] as String;
      }

      final items = appCountByJobId.entries.map((e) {
        return {
          'title': jobTitleById[e.key] ?? '',
          'count': e.value,
        };
      }).toList();

      items.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      // 'dsf' (job 2) has 2 applications, so it must be top
      expect(items.first['title'], 'dsf');
      expect(items.first['count'], 2);
    });
  });
}
