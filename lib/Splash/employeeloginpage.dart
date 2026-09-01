import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/Splash/employeesignuppage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> with TickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _mobileFocus = FocusNode();
  bool _mobileFocused = false;

  // ── OTP STATE ───────────────────────────────────────────
  bool _otpSent = false; // false = show mobile field, true = show OTP boxes
  final int _otpLength = 6;
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;

  // Floating dots animation
  late final AnimationController _floatController;

  // Job-search icon cycle animation (briefcase -> search -> location)
  late final AnimationController _iconCycleController;
  int _iconIndex = 0;
  final List<IconData> _jobIcons = const [
    Icons.emoji_people_rounded,
    Icons.work_outline_rounded,
    Icons.search_rounded,
    Icons.location_on_rounded,
  ];

  @override
  void initState() {
    super.initState();

    _mobileFocus.addListener(() {
      setState(() => _mobileFocused = _mobileFocus.hasFocus);
    });

    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _otpFocusNodes = List.generate(_otpLength, (_) => FocusNode());

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _iconCycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startIconCycle();
  }

  void _startIconCycle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      await _iconCycleController.reverse();
      if (!mounted) return false;
      setState(() {
        _iconIndex = (_iconIndex + 1) % _jobIcons.length;
      });
      await _iconCycleController.forward();
      return mounted;
    });
    _iconCycleController.forward();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocus.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _floatController.dispose();
    _iconCycleController.dispose();
    super.dispose();
  }

  // ── SEND OTP HANDLER ───────────────────────────────────────
  void _handleSendOtp() {
    final cleanPhone = _mobileController.text.replaceAll(' ', '');
    if (cleanPhone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    // TODO: call your send-OTP API here

    setState(() => _otpSent = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
    });
  }

  // ── VERIFY OTP + LOGIN HANDLER ─────────────────────────────
  void _handleVerifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit OTP')),
      );
      return;
    }

    // TODO: call your verify-OTP API here

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeHomePage()),
    );
  }

  // ── RESEND OTP ──────────────────────────────────────────────
  void _handleResendOtp() {
    // TODO: call your resend-OTP API here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent')),
    );
  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── LAYERED BACK WAVE DECORATIVE ──
          Opacity(
            opacity: 0.35,
            child: ClipPath(
              clipper: _BottomWaveClipperOffset(),
              child: Container(
                width: double.infinity,
                height: 320,
                color: AppColors.primaryLight,
              ),
            ),
          ),

          // ── PURPLE DEEP WAVE HEADER ──
          ClipPath(
            clipper: _BottomWaveClipper(),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
              ),
            ),
          ),

          // ── DECORATIVE DOTS ──
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final t = _floatController.value;
              return Stack(
                children: [
                  _floatingDot(top: 90, left: 40, color: AppColors.coral, size: 8, t: t, phase: 0.0),
                  _floatingDot(top: 200, right: 120, color: AppColors.warning, size: 7, t: t, phase: 0.4),
                  _floatingDot(top: 320, right: 30, color: AppColors.mint, size: 7, t: t, phase: 0.45),
                  _floatingDot(top: 360, left: 20, color: AppColors.primary, size: 6, t: t, phase: 0.55),
                  _floatingDot(top: 430, left: 60, color: AppColors.warning, size: 6, t: t, phase: 0.6),
                  _floatingDot(top: 470, right: 70, color: AppColors.pink, size: 6, t: t, phase: 0.75),
                  _floatingDot(top: 520, left: 150, color: AppColors.primaryDeep, size: 8, t: t, phase: 0.9),
                  _floatingDot(top: 500, right: 160, color: AppColors.mint, size: 6, t: t, phase: 0.5),
                  _floatingDot(top: 600, left: 36, color: AppColors.coral, size: 7, t: t, phase: 0.2),
                  _floatingDot(top: 640, right: 45, color: AppColors.primary, size: 6, t: t, phase: 0.35),
                  _floatingDot(top: 700, left: 200, color: AppColors.pink, size: 7, t: t, phase: 0.65),
                  _floatingDot(top: 760, right: 100, color: AppColors.mint, size: 6, t: t, phase: 0.8),
                  _floatingDot(top: 820, left: 90, color: AppColors.warning, size: 6, t: t, phase: 0.1),
                  _floatingDot(top: 390, right: 200, color: AppColors.coral, size: 6, t: t, phase: 0.7),
                  _floatingDot(top: 450, left: 220, color: AppColors.pink, size: 7, t: t, phase: 0.85),
                  _floatingDot(top: 560, right: 40, color: AppColors.primary, size: 6, t: t, phase: 0.05),
                  _floatingDot(top: 670, left: 100, color: AppColors.mint, size: 8, t: t, phase: 0.5),
                  _floatingDot(top: 730, right: 220, color: AppColors.warning, size: 6, t: t, phase: 0.95),
                  _floatingDot(top: 860, right: 60, color: AppColors.coral, size: 6, t: t, phase: 0.3),
                  _floatingDot(top: 900, left: 140, color: AppColors.pink, size: 7, t: t, phase: 0.15),
                  _floatingDot(top: 940, right: 90, color: AppColors.mint, size: 6, t: t, phase: 0.6),
                  _floatingDot(top: 980, left: 60, color: AppColors.warning, size: 7, t: t, phase: 0.4),
                ],
              );
            },
          ),

          // ── MAIN CONTENT ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  // Illustration Badge (cycling job-search icons with rotating ring)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _floatController.value * 2 * pi,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: FadeTransition(
                          opacity: _iconCycleController,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                              CurvedAnimation(parent: _iconCycleController, curve: Curves.easeOut),
                            ),
                            child: Icon(
                              _jobIcons[_iconIndex],
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'WELCOME',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _otpSent ? 'Verify your number' : 'Sign in to continue',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.12),

                  // ── FORM FIELDS ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile Number Field (only before OTP is sent)
                        if (!_otpSent) ...[
                          _buildLabeledField(
                            label: 'Mobile Number',
                            controller: _mobileController,
                            focusNode: _mobileFocus,
                            isFocused: _mobileFocused,
                            hint: 'Enter your mobile number',
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 26),
                        ],

                        // OTP Boxes (only after OTP is sent)
                        if (_otpSent) ...[
                          RichText(
                            text: TextSpan(
                              text: 'OTP sent to ',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: () {
                                    final phone = _mobileController.text.replaceAll(' ', '');
                                    final masked = phone.length >= 10
                                        ? '${phone.substring(0, 2)}******${phone.substring(8)}'
                                        : phone;
                                    return '+91 $masked';
                                  }(),
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildOtpBoxes(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: _handleResendOtp,
                                child: Text(
                                  'Resend OTP',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                        ],

                        // Send OTP / Verify Button
                        GestureDetector(
                          onTap: _otpSent ? _handleVerifyOtp : _handleSendOtp,
                          child: Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.primaryDeep,
                                  AppColors.primary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _otpSent ? 'VERIFY & LOGIN' : 'SEND OTP',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.buttonText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.buttonText,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Sign Up link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EmployeeSignUpPage()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'SIGN UP',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingDot({
    double? top,
    double? left,
    double? right,
    required Color color,
    required double size,
    required double t,
    required double phase,
  }) {
    final angle = (t + phase) * 2 * pi;
    final dx = sin(angle) * 10;
    final dy = cos(angle * 1.3) * 10;

    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }

  // ── MOBILE FIELD WITH STADIUM BORDER ──
  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isFocused ? AppColors.primary : AppColors.border,
              width: isFocused ? 2.0 : 1.2,
            ),
            color: isFocused ? AppColors.primary.withOpacity(0.015) : Colors.white,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isFocused ? AppColors.primary : AppColors.unselected),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  maxLength: 28,
                  inputFormatters: [DigitSpacingInputFormatter()],
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 6-DIGIT OTP BOXES (styled to match stadium theme) ──
  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 46,
          height: 54,
          child: AnimatedBuilder(
            animation: _otpFocusNodes[index],
            builder: (context, child) {
              final isFocused = _otpFocusNodes[index].hasFocus;
              return Container(
                decoration: BoxDecoration(
                  color: isFocused ? AppColors.primary.withOpacity(0.015) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFocused ? AppColors.primary : AppColors.border,
                    width: isFocused ? 2.0 : 1.2,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: child,
              );
            },
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (index < _otpLength - 1) {
                    FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                } else {
                  if (index > 0) {
                    FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
                  }
                }
              },
            ),
          ),
        );
      }),
    );
  }
}

// ── Wave/curve clipper for the purple header ──
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height + 20,
      size.width * 0.5,
      size.height - 50,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 120,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Offset wave/curve clipper for decorative purple layer ──
class _BottomWaveClipperOffset extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width * 0.3,
      size.height - 100,
      size.width * 0.6,
      size.height - 30,
    );

    path.quadraticBezierTo(
      size.width * 0.8,
      size.height + 25,
      size.width,
      size.height - 55,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Formatter to space out input digits (e.g. 9  8  7  6  5  4  3  2  1  0) ──
class DigitSpacingInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String cleanText = newValue.text.replaceAll(' ', '');
    final String digits = cleanText.length > 10 ? cleanText.substring(0, 10) : cleanText;
    final String formatted = digits.split('').join('  ');

    int digitsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end && i < newValue.text.length; i++) {
      if (newValue.text[i] != ' ') {
        digitsBeforeCursor++;
      }
    }

    int newOffset = 0;
    int digitIndex = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (formatted[i] != ' ') {
        digitIndex++;
      }
      if (digitIndex == digitsBeforeCursor) {
        newOffset = i + 1;
        break;
      }
    }

    while (newOffset < formatted.length && formatted[newOffset] == ' ') {
      newOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}