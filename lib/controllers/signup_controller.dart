import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class SignupController {
  int? employeeId;
  String message = '';
  String? token;
  Employee? employee;

  // Stored for resend
  String fullName = '';
  String email = '';
  String phone = '';
  int companyId = 1;
  String industry = '';
  String businessName = '';
  String establishmentYear = '';

  Future<bool> signup({
    required String fullName,
    required String email,
    required String phone,
    required String industry,
    required String businessName,
    required String establishmentYear,
    int companyId = 1,
  }) async {
    this.fullName = fullName;
    this.email = email;
    this.phone = phone;
    this.companyId = companyId;
    this.industry = industry;
    this.businessName = businessName;
    this.establishmentYear = establishmentYear;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (businessName.trim().isNotEmpty) {
        await prefs.setString('saved_business_name', businessName.trim());
      }
    } catch (_) {}

    final result = await ApiService.signup(
      fullName: fullName,
      email: email,
      phone: phone,
      companyId: companyId,
      industry: industry,
      businessName: businessName,
      establishmentYear: establishmentYear,
    );

    message = result['message']?.toString() ?? '';

    if (result['success'] == true) {
      final rawId = result['employee_id'];
      if (rawId is int) {
        employeeId = rawId;
      } else if (rawId != null) {
        employeeId = int.tryParse(rawId.toString());
      }
      return true;
    }
    return false;
  }

  Future<bool> resendOtp() async {
    if (phone.isEmpty || email.isEmpty) {
      message = 'Phone or email missing';
      return false;
    }
    return signup(
      fullName: fullName,
      email: email,
      phone: phone,
      companyId: companyId,
      industry: industry,
      businessName: businessName,
      establishmentYear: establishmentYear,
    );
  }

  Future<bool> verifyOtp(String otp) async {
    if (employeeId == null) {
      message = 'Employee ID missing, parat signup kara';
      return false;
    }

    final result = await ApiService.verifySignupOtp(
      employeeId: employeeId!,
      otp: otp,
    );

    message = result['message']?.toString() ?? '';

    if (result['success'] == true) {
      token = result['token']?.toString();
      if (result['employee'] is Map<String, dynamic>) {
        employee = Employee.fromJson(result['employee'] as Map<String, dynamic>);
      }
      if (employee == null || employee!.fullName.isEmpty) {
        employee = Employee(
          id: employee?.id ?? employeeId ?? 0,
          fullName: employee != null && employee!.fullName.isNotEmpty
              ? employee!.fullName
              : fullName,
          email: employee != null && employee!.email.isNotEmpty
              ? employee!.email
              : email,
          phone: employee != null && employee!.phone.isNotEmpty
              ? employee!.phone
              : phone,
          companyId: employee?.companyId ?? companyId,
          industry: employee?.industry ?? industry,
          businessName: employee?.businessName ?? businessName,
          establishmentYear: employee?.establishmentYear ?? establishmentYear,
        );
      }
      await UserSession.saveSession(employee: employee, token: token);
      return true;
    }
    return false;
  }
}