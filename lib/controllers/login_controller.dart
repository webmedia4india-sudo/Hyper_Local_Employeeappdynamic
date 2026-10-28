import '../models/employee_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class LoginController {
  String message = '';
  String? token;
  Employee? employee;
  String phone = '';

  Future<bool> requestOtp(String phone) async {
    this.phone = phone.trim();
    final result = await ApiService.loginRequestOtp(phone: this.phone);
    message = result['message']?.toString() ?? '';
    return result['success'] == true;
  }

  Future<bool> resendOtp() async {
    if (phone.isEmpty) {
      message = 'Phone number missing';
      return false;
    }
    return requestOtp(phone);
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    this.phone = phone.trim();
    final result = await ApiService.loginVerifyOtp(phone: this.phone, otp: otp.trim());
    message = result['message']?.toString() ?? '';

    if (result['success'] == true) {
      token = result['token']?.toString();
      if (result['employee'] is Map<String, dynamic>) {
        employee = Employee.fromJson(result['employee'] as Map<String, dynamic>);
      } else if (result['data'] is Map<String, dynamic>) {
        final dataMap = result['data'] as Map<String, dynamic>;
        if (dataMap['employee'] is Map<String, dynamic>) {
          employee = Employee.fromJson(dataMap['employee'] as Map<String, dynamic>);
        } else {
          employee = Employee.fromJson(dataMap);
        }
      } else if (result['user'] is Map<String, dynamic>) {
        employee = Employee.fromJson(result['user'] as Map<String, dynamic>);
      } else {
        employee = Employee(
          id: int.tryParse(result['id']?.toString() ?? '') ?? 0,
          fullName: result['full_name']?.toString() ??
              result['fullName']?.toString() ??
              result['name']?.toString() ??
              '',
          email: result['email']?.toString() ?? '',
          phone: this.phone,
        );
      }

      if (employee != null && employee!.fullName.isEmpty) {
        final fallbackName = result['full_name']?.toString() ??
            result['fullName']?.toString() ??
            result['name']?.toString() ??
            '';
        if (fallbackName.isNotEmpty) {
          employee = Employee(
            id: employee!.id,
            fullName: fallbackName,
            email: employee!.email,
            phone: employee!.phone,
            companyId: employee!.companyId,
            industry: employee!.industry,
            businessName: employee!.businessName,
            establishmentYear: employee!.establishmentYear,
          );
        }
      }

      await UserSession.saveSession(employee: employee, token: token);
      return true;
    }
    return false;
  }
}