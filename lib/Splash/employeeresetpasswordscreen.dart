import 'package:flutter/material.dart';
import 'package:hyper_local_employee/Splash/employeeloginpage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
class EmployeeResetPasswordScreen extends StatefulWidget {
  const EmployeeResetPasswordScreen({super.key});

  @override
  State<EmployeeResetPasswordScreen> createState() =>
      _EmployeeResetPasswordScreenState();
}

class _EmployeeResetPasswordScreenState
    extends State<EmployeeResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final FocusNode _newPassFocus = FocusNode();
  final FocusNode _confirmPassFocus = FocusNode();

  bool _newPassFocused = false;
  bool _confirmPassFocused = false;

  bool hideNew = true;
  bool hideConfirm = true;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _newPassFocus.addListener(() {
      setState(() => _newPassFocused = _newPassFocus.hasFocus);
    });

    _confirmPassFocus.addListener(() {
      setState(() => _confirmPassFocused = _confirmPassFocus.hasFocus);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  Widget passwordField({
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.otpBoxBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFocused ? AppColors.primary : Colors.transparent,
          width: 2.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textHint,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isFocused ? AppColors.primary : AppColors.textHint,
          ),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: isFocused ? AppColors.primary : AppColors.textHint,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Reset Password",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Create a new password for your account",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 25),

                        passwordField(
                          hint: "New Password",
                          controller: newPassController,
                          focusNode: _newPassFocus,
                          isFocused: _newPassFocused,
                          obscure: hideNew,
                          toggle: () {
                            setState(() {
                              hideNew = !hideNew;
                            });
                          },
                        ),

                        const SizedBox(height: 15),

                        passwordField(
                          hint: "Confirm Password",
                          controller: confirmPassController,
                          focusNode: _confirmPassFocus,
                          isFocused: _confirmPassFocused,
                          obscure: hideConfirm,
                          toggle: () {
                            setState(() {
                              hideConfirm = !hideConfirm;
                            });
                          },
                        ),

                        const SizedBox(height: 25),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmployeeLoginPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 55,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Reset Password",
                                style: TextStyle(
                                  color: AppColors.buttonText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}