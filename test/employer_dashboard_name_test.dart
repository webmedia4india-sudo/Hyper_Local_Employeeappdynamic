import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/models/employee_model.dart';
import 'package:hyper_local_employee/services/user_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.init();
    await UserSession.clearSession();
  });

  group('Employer Name Dynamic Display and Session Lifecycle', () {
    test('Scenario 1 & 2: Employer A and Employer B sessions set name correctly', () async {
      // 1. Employer A logs in
      final employerA = Employee(
        id: 101,
        fullName: 'Employer A',
        email: 'employerA@test.com',
        phone: '9876543210',
      );
      await UserSession.saveSession(employee: employerA, token: 'tokenA');

      expect(UserSession.isLoggedIn, isTrue);
      expect(UserSession.userName, equals('Employer A'));

      // 2. Logout clears Employer A data
      await UserSession.clearSession();
      expect(UserSession.isLoggedIn, isFalse);
      expect(UserSession.userName, equals(''));

      // 3. Employer B logs in
      final employerB = Employee(
        id: 102,
        fullName: 'Employer B',
        email: 'employerB@test.com',
        phone: '9123456780',
      );
      await UserSession.saveSession(employee: employerB, token: 'tokenB');

      expect(UserSession.isLoggedIn, isTrue);
      expect(UserSession.userName, equals('Employer B'));
      expect(UserSession.userEmail, equals('employerB@test.com'));
    });

    test('Scenario 3: Name persists across app restart when session is valid', () async {
      final employer = Employee(
        id: 201,
        fullName: 'Kavita Verma',
        email: 'kavita@company.com',
        phone: '9988776655',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_employee', jsonEncode(employer.toJson()));
      await prefs.setString('auth_token', 'token_kavita');

      await UserSession.init();

      expect(UserSession.isLoggedIn, isTrue);
      expect(UserSession.userName, equals('Kavita Verma'));
      expect(UserSession.userEmail, equals('kavita@company.com'));
    });

    testWidgets('Scenario 4: Dashboard displays Employer A registered name in header and drawer', (tester) async {
      final employerA = Employee(
        id: 301,
        fullName: 'Aditi Sharma',
        email: 'aditi@sharma-enterprises.com',
        phone: '9822001122',
      );
      await UserSession.saveSession(employee: employerA, token: 'token_aditi');

      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EmployeeDashboardPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify header contains registered name "Hi, Aditi Sharma"
      expect(find.text('Hi, Aditi Sharma'), findsOneWidget);

      // Open drawer
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify drawer contains registered name and email
      expect(find.text('Aditi Sharma'), findsOneWidget);
      expect(find.text('aditi@sharma-enterprises.com'), findsOneWidget);
    });

    testWidgets('Scenario 5: Dashboard updates dynamically when Employer B logs in', (tester) async {
      final employerB = Employee(
        id: 302,
        fullName: 'Vikram Mehta',
        email: 'vikram@mehta-tech.com',
        phone: '9733445566',
      );
      await UserSession.saveSession(employee: employerB, token: 'token_vikram');

      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EmployeeDashboardPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify header contains registered name "Hi, Vikram Mehta"
      expect(find.text('Hi, Vikram Mehta'), findsOneWidget);
      expect(find.text('Hi, Rahul'), findsNothing);

      // Open drawer
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify drawer contains registered name
      expect(find.text('Vikram Mehta'), findsOneWidget);
      expect(find.text('Amit Kadam'), findsNothing);
    });
  });
}
