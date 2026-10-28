import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/controllers/signup_controller.dart';
import 'package:hyper_local_employee/models/employee_model.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/services/user_session.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
class OtpSignUpPage extends StatefulWidget {
  final String phoneNumber;
  final int employeeId;
  final SignupController? signupController;

  const OtpSignUpPage({
    super.key,
    required this.phoneNumber,
    required this.employeeId,
    this.signupController,
  });

  @override
  State<OtpSignUpPage> createState() => _OtpSignUpPageState();
}

class _OtpSignUpPageState extends State<OtpSignUpPage> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 30;

  final List<TextEditingController> _otpControllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _isVerifying = false;
  bool _isResending = false;
  late int _employeeId;

  @override
  void initState() {
    super.initState();
    _employeeId = widget.employeeId;
    _startResendTimer();
  }

  void _startResendTimer() {
    _secondsLeft = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _handleResend() async {
    if (_secondsLeft != 0 || _isResending) return;

    setState(() => _isResending = true);

    bool success = false;
    String message = '';

    if (widget.signupController != null) {
      success = await widget.signupController!.resendOtp();
      message = widget.signupController!.message;
      if (widget.signupController!.employeeId != null) {
        _employeeId = widget.signupController!.employeeId!;
      }
    } else {
      message = 'Resend not available. Please return to signup.';
    }

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isNotEmpty ? message : "OTP resent successfully"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isNotEmpty ? message : "Failed to resend OTP"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleChangeNumber() {
    Navigator.pop(context);
  }

  Future<void> _handleVerify() async {
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the complete 6-digit OTP"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    bool success = false;
    String message = '';

    if (widget.signupController != null) {
      success = await widget.signupController!.verifyOtp(otp);
      message = widget.signupController!.message;
    } else {
      final result = await ApiService.verifySignupOtp(
        employeeId: _employeeId,
        otp: otp,
      );
      success = result['success'] == true;
      message = result['message']?.toString() ?? '';
      if (success) {
        Employee? emp;
        if (result['employee'] is Map<String, dynamic>) {
          emp = Employee.fromJson(result['employee'] as Map<String, dynamic>);
        } else if (result['data'] is Map<String, dynamic>) {
          final d = result['data'] as Map<String, dynamic>;
          if (d['employee'] is Map<String, dynamic>) {
            emp = Employee.fromJson(d['employee'] as Map<String, dynamic>);
          } else {
            emp = Employee.fromJson(d);
          }
        } else if (result['user'] is Map<String, dynamic>) {
          emp = Employee.fromJson(result['user'] as Map<String, dynamic>);
        }
        final prefs = await SharedPreferences.getInstance();
        final savedBusName = prefs.getString('saved_business_name');
        final rawName = (emp != null && emp.fullName.isNotEmpty)
            ? emp.fullName
            : (result['full_name']?.toString() ??
                result['fullName']?.toString() ??
                result['name']?.toString() ??
                '');
        if (emp == null || emp.businessName == null || emp.businessName!.isEmpty || emp.fullName.isEmpty) {
          emp = Employee(
            id: emp?.id ?? _employeeId,
            fullName: rawName.isNotEmpty ? rawName : (emp?.fullName ?? ''),
            email: emp?.email ?? '',
            phone: (emp != null && emp.phone.isNotEmpty) ? emp.phone : widget.phoneNumber,
            companyId: emp?.companyId,
            industry: emp?.industry,
            businessName: (emp?.businessName != null && emp!.businessName!.isNotEmpty)
                ? emp.businessName
                : savedBusName,
            establishmentYear: emp?.establishmentYear,
          );
        }
        await UserSession.saveSession(employee: emp, token: result['token']?.toString());
      }
    }

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isNotEmpty ? message : "Account verified successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const EmployeeHomePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isNotEmpty ? message : "OTP verification failed"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleContinueAsGuest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeDashboardPage()),
    );
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (index == _otpLength - 1 && value.isNotEmpty) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── ILLUSTRATION ─────────────────────────────
              Center(
                child: SizedBox(
                  height: 160,
                  child: Image.asset(
                    'assets/images/new_onboarding_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.verified_user_rounded,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── TITLE ─────────────────────────────
              const Text(
                "Enter OTP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),

              // ── SUBTITLE + CHANGE ─────────────────────────────
              Row(
                children: [
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: "OTP sent to "),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _handleChangeNumber,
                    child: const Text(
                      "Change",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── OTP BOXES ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: 46,
                    height: 54,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: AppColors.otpBoxBg,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.otpBoxBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.otpBoxBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // ── RESEND TIMER ─────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _handleResend,
                  child: Text(
                    _secondsLeft > 0
                        ? "Resend in ${_secondsLeft}s"
                        : "Resend OTP",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _secondsLeft > 0
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── VERIFY & CONTINUE BUTTON ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.buttonText,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Verify & Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── ALREADY HAVE ACCOUNT ─────────────────────────────
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── CONTINUE AS GUEST ─────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _handleContinueAsGuest,
                  child: const Text(
                    "Continue as Guest",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}