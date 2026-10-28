import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_local_employee/controllers/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('LoginController initializes with empty state', () {
    final controller = LoginController();
    expect(controller.phone, isEmpty);
    expect(controller.message, isEmpty);
    expect(controller.token, isNull);
    expect(controller.employee, isNull);
  });
}
