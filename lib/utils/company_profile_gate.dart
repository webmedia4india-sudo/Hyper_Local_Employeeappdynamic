import 'package:flutter/material.dart';
import '../models/company_profile_model.dart';
import '../services/api_service.dart';
import '../utils/app-colorpage.dart';
import '../Pages/employeecomapanyprofilepage.dart';

class CompanyProfileGate {
  /// Checks whether the employer's company profile is 100% complete.
  /// If not complete, displays a dialog prompting the user to complete their profile,
  /// with a direct button to navigate to [EmployeeCompanyProfilePage].
  /// Returns `true` if 100% complete, or `false` if incomplete or on error.
  static Future<bool> ensureProfileComplete(BuildContext context) async {
    // Show a lightweight loading indicator while checking profile
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    CompanyProfileModel? profile;
    int percentage = 0;

    try {
      final res = await ApiService.getMyCompanyProfile();
      if (res['success'] == true && res['company_profile'] != null) {
        final profileMap = res['company_profile'] as Map<String, dynamic>;
        profile = CompanyProfileModel.fromJson(profileMap);

        // Read backend profile_completion if available, or compute on model
        if (res['profile_completion'] != null &&
            res['profile_completion']['percentage'] is num) {
          percentage = (res['profile_completion']['percentage'] as num).round();
        } else {
          percentage = profile.profileCompletionPercentage;
        }
      }
    } catch (e) {
      debugPrint('[CompanyProfileGate] Error checking profile: $e');
    } finally {
      // Dismiss the loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) return false;

    if (profile != null && percentage == 100) {
      return true;
    }

    // Show incomplete profile dialog
    await showIncompleteDialog(
      context,
      percentage: percentage,
      message: 'Please complete your Company Profile to 100% before posting a job.',
    );

    return false;
  }

  /// Displays the modal dialog explaining that 100% completion is required
  /// and provides navigation to [EmployeeCompanyProfilePage].
  static Future<void> showIncompleteDialog(
    BuildContext context, {
    required int percentage,
    String? message,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: AppColors.coral,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Profile Incomplete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message ??
                    'Please complete your Company Profile to 100% before posting a job.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Completion:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: percentage >= 100
                          ? AppColors.mint
                          : AppColors.coral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (percentage / 100.0).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage >= 100 ? AppColors.mint : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Required sections: Company Overview, Address & Branch, Contact Info, and Verification Documents.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeCompanyProfilePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Complete Profile'),
            ),
          ],
        );
      },
    );
  }
}
