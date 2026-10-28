import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyper_local_employee/Pages/otpsignuppage.dart';
import 'package:hyper_local_employee/controllers/signup_controller.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeSignUpPage extends StatefulWidget {
  const EmployeeSignUpPage({super.key});

  @override
  State<EmployeeSignUpPage> createState() => _EmployeeSignUpPageState();
}

class _EmployeeSignUpPageState extends State<EmployeeSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _establishmentYearController = TextEditingController();

  final SignupController _signupController = SignupController();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  String? _selectedIndustry;
  List<String> _industryOptions = [];
  bool _isLoadingIndustries = true;
  bool _isIndustryError = false;

  @override
  void initState() {
    super.initState();
    _loadIndustries();
  }

  Future<void> _loadIndustries() async {
    setState(() {
      _isLoadingIndustries = true;
      _isIndustryError = false;
    });
    try {
      final industries = await ApiService.fetchIndustries();
      if (!mounted) return;
      if (industries.isEmpty) {
        setState(() {
          _industryOptions = [];
          _isLoadingIndustries = false;
          _isIndustryError = true;
        });
      } else {
        setState(() {
          _industryOptions = industries;
          _isLoadingIndustries = false;
          _isIndustryError = false;
          if (_selectedIndustry != null && !_industryOptions.contains(_selectedIndustry)) {
            _selectedIndustry = null;
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _industryOptions = [];
        _isLoadingIndustries = false;
        _isIndustryError = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _establishmentYearController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.replaceAll(' ', '').trim();
    final businessName = _businessNameController.text.trim();
    final establishmentYear = _establishmentYearController.text.trim();

    if (_selectedIndustry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your industry"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your business/company name"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your full name"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (establishmentYear.isEmpty || establishmentYear.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid establishment year"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit phone number"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please agree to the Terms & Conditions and Privacy Policy"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _signupController.signup(
      fullName: name,
      email: email,
      phone: phone,
      industry: _selectedIndustry!,
      businessName: businessName,
      establishmentYear: establishmentYear,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_signupController.message.isNotEmpty
              ? _signupController.message
              : "OTP sent successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpSignUpPage(
            phoneNumber: phone,
            employeeId: _signupController.employeeId ?? 0,
            signupController: _signupController,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_signupController.message.isNotEmpty
              ? _signupController.message
              : "Signup failed. Please try again."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── TERMS & CONDITIONS POPUP ───────────────────────────────
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _buildPolicyDialog(
          title: "Terms & Conditions",
          content: """
Welcome to our app. By creating an account, you agree to the following terms:

1. Account Responsibility
You are responsible for maintaining the confidentiality of your account and for all activities that occur under it.

2. Acceptable Use
You agree not to misuse the platform, including but not limited to posting false information, spamming, or engaging in fraudulent activity.

3. Job Listings & Applications
All job listings and applications submitted through the platform must be accurate and lawful. We reserve the right to remove any content that violates these terms.

4. Termination
We reserve the right to suspend or terminate accounts that violate these terms without prior notice.

5. Changes to Terms
We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.

6. Limitation of Liability
We are not liable for any indirect, incidental, or consequential damages arising from your use of the platform.

By tapping "Read and Understand 👍", you confirm that you have read, understood, and accepted these Terms & Conditions.
""",
        );
      },
    );
  }

  // ── PRIVACY POLICY POPUP ───────────────────────────────────
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _buildPolicyDialog(
          title: "Privacy Policy",
          content: """
Your privacy is important to us. This policy explains how we collect, use, and protect your information.

1. Information We Collect
We collect information you provide during sign up, such as your name, email address, and phone number.

2. How We Use Your Information
Your information is used to create and manage your account, connect you with relevant job opportunities, and improve our services.

3. Data Sharing
We do not sell your personal information. We may share data with trusted service providers strictly to operate the platform.

4. Data Security
We implement reasonable security measures to protect your data from unauthorized access, alteration, or disclosure.

5. Your Rights
You may request access to, correction of, or deletion of your personal data at any time by contacting our support team.

6. Cookies & Tracking
We may use cookies or similar technologies to enhance your experience and analyze app usage.

7. Changes to This Policy
We may update this Privacy Policy periodically. Continued use of the app indicates acceptance of the revised policy.

By tapping "Read and Understand 👍", you acknowledge that you have read and understood this Privacy Policy.
""",
        );
      },
    );
  }

  // ── SHARED POPUP UI ─────────────────────────────────────────
  Widget _buildPolicyDialog({required String title, required String content}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    content.trim(),
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Read and Understand 👍",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LOGO ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 28),
                  child: Center(
                    child: Image.asset(
                      'assets/images/new_onboarding_logo.png',
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),

                const Text(
                  "I'm an Employer",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create your account and hire top talent",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Industry
                _buildLabel("Select Industry"),
                _buildIndustryDropdown(),
                const SizedBox(height: 18),

                // Business Name
                _buildLabel("Business Name"),
                _buildTextField(
                  controller: _businessNameController,
                  hint: "Enter business/company name",
                  icon: Icons.storefront_outlined,
                ),
                const SizedBox(height: 18),

                // Full Name
                _buildLabel("Full Name"),
                _buildTextField(
                  controller: _nameController,
                  hint: "Enter contact person's full name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 18),

                // Establishment Year
                _buildLabel("Establishment Year"),
                _buildTextField(
                  controller: _establishmentYearController,
                  hint: "e.g. 2018",
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),

                // Phone
                _buildLabel("Mobile Number"),
                _buildTextField(
                  controller: _phoneController,
                  hint: "Enter 10-digit mobile number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),

                // Email
                _buildLabel("Email Address"),
                _buildTextField(
                  controller: _emailController,
                  hint: "Enter business email address",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: "I agree to the "),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showTermsDialog,
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showPrivacyPolicyDialog,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.buttonText,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),

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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildIndustryDropdown() {
    if (_isLoadingIndustries) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            SizedBox(width: 12),
            Text(
              "Loading industries...",
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    if (_isIndustryError || _industryOptions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Failed to load industries",
                style: TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: _loadIndustries,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Retry",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedIndustry,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textHint,
      ),
      decoration: InputDecoration(
        hintText: "Choose Industry",
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: _industryOptions.map((industry) {
        return DropdownMenuItem<String>(value: industry, child: Text(industry));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedIndustry = value;
        });
      },
    );
  }
}