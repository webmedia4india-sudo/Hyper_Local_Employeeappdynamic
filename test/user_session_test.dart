import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local_employee/models/employee_model.dart';
import 'package:hyper_local_employee/services/user_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.init();
    await UserSession.clearSession();
  });

  test('UserSession stores and retrieves employee details correctly', () async {
    final employee = Employee(
      id: 101,
      fullName: 'Sarthak Patil',
      email: 'sarthak.patil@example.com',
      phone: '9876543210',
    );

    await UserSession.saveSession(employee: employee, token: 'fake_jwt_token');

    expect(UserSession.isLoggedIn, isTrue);
    expect(UserSession.userName, equals('Sarthak Patil'));
    expect(UserSession.displayName, equals('Sarthak'));
    expect(UserSession.userEmail, equals('sarthak.patil@example.com'));
    expect(UserSession.userInitials, equals('SP'));
    expect(UserSession.token, equals('fake_jwt_token'));
  });

  test('UserSession clears session correctly on logout', () async {
    final employee = Employee(
      id: 102,
      fullName: 'Rahul Sharma',
      email: 'rahul@test.com',
      phone: '9988776655',
    );

    await UserSession.saveSession(employee: employee, token: 'token123');
    expect(UserSession.isLoggedIn, isTrue);

    await UserSession.clearSession();
    expect(UserSession.isLoggedIn, isFalse);
    expect(UserSession.userName, equals(''));
    expect(UserSession.displayName, equals('User'));
    expect(UserSession.userEmail, equals(''));
    expect(UserSession.userInitials, equals('U'));
  });
}
