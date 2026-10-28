import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Overview Dynamic Pipeline Counting & Percentage Logic', () {
    test('Calculates pipeline counts without double-counting', () {
      final apps = [
        {
          'application_id': 1,
          'application_status': 'applied',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 2,
          'application_status': 'new',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 3,
          'application_status': 'shortlisted',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 4,
          'application_status': 'shortlisted',
          'interview_status': 'scheduled',
          'offer_status': null,
        },
        {
          'application_id': 5,
          'application_status': 'interview',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 6,
          'application_status': 'shortlisted',
          'interview_status': null,
          'offer_status': 'Generated',
        },
        {
          'application_id': 7,
          'application_status': 'offer_letter',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 8,
          'application_status': 'selected',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 9,
          'application_status': 'hired',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 10,
          'application_status': 'rejected',
          'interview_status': null,
          'offer_status': null,
        },
        {
          'application_id': 11,
          'application_status': 'withdrawn',
          'interview_status': null,
          'offer_status': null,
        },
      ];

      int hired = 0;
      int offers = 0;
      int interviews = 0;
      int shortlisted = 0;
      int newApps = 0;
      int others = 0;

      for (final app in apps) {
        final st = (app['application_status'] ?? '').toString().toLowerCase().trim();
        final intSt = (app['interview_status'] ?? '').toString().toLowerCase().trim();
        final offSt = (app['offer_status'] ?? '').toString().toLowerCase().trim();

        if (st == 'hired' || st == 'selected' || st == 'offer_accepted' || offSt == 'accepted') {
          hired++;
        } else if (st == 'offer_letter' ||
            st == 'offer' ||
            st == 'offer_pending' ||
            (offSt.isNotEmpty && offSt != 'declined')) {
          offers++;
        } else if (st == 'interview' || intSt == 'scheduled' || intSt == 'rescheduled') {
          interviews++;
        } else if (st == 'shortlisted') {
          shortlisted++;
        } else if (st == 'applied' || st == 'new' || st.isEmpty) {
          newApps++;
        } else {
          others++;
        }
      }

      final total = apps.length;
      expect(total, 11);
      expect(newApps, 2); // id 1, 2
      expect(shortlisted, 1); // id 3
      expect(interviews, 2); // id 4, 5
      expect(offers, 2); // id 6, 7
      expect(hired, 2); // id 8, 9
      expect(others, 2); // id 10, 11

      // Sum of segments must equal total
      expect(newApps + shortlisted + interviews + offers + hired + others, total);
    });

    test('Zero total applications handled safely without division by zero', () {
      const int total = 0;
      const int count = 0;

      final double pct = total > 0 ? (count / total) * 100.0 : 0.0;
      String pctText;
      if (total == 0 || count <= 0) {
        pctText = "0%";
      } else if (pct < 1.0) {
        pctText = "<1%";
      } else {
        pctText = "${pct.round()}%";
      }

      expect(pct, 0.0);
      expect(pctText, "0%");
    });

    test('Non-zero small count shows <1% instead of misleading 0%', () {
      const int total = 1000;
      const int count = 2; // 0.2%

      final double pct = total > 0 ? (count / total) * 100.0 : 0.0;
      String pctText;
      if (total == 0 || count <= 0) {
        pctText = "0%";
      } else if (pct < 1.0) {
        pctText = "<1%";
      } else {
        pctText = "${pct.round()}%";
      }

      expect(pct, 0.2);
      expect(pctText, "<1%");
    });

    test('Regular percentage rounds correctly', () {
      const int total = 152;
      const int newCount = 48; // 31.578% -> 32%
      const int shortlistedCount = 15; // 9.868% -> 10%

      String formatPct(int count) {
        final double pct = (count / total) * 100.0;
        if (pct < 1.0) return "<1%";
        return "${pct.round()}%";
      }

      expect(formatPct(newCount), "32%");
      expect(formatPct(shortlistedCount), "10%");
    });
  });
}
