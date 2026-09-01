import 'package:flutter/material.dart';
import '../utils/app-colorpage.dart'; // adjust path as per your project structure

class EmployeeSettingPage extends StatelessWidget {
  const EmployeeSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _settingTile(
              icon: Icons.notifications_none_rounded,
              label: "Notification Settings",
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _settingTile(
              icon: Icons.person_outline,
              label: "Account Settings",
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _settingTile(
              icon: Icons.groups_outlined,
              label: "Users & Permissions",
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _settingTile(
              icon: Icons.shield_outlined,
              label: "Security",
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _settingTile(
              icon: Icons.privacy_tip_outlined,
              label: "Privacy Policy",
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _settingTile(
              icon: Icons.help_outline,
              label: "Help & Support",
              onTap: () {},
            ),
            const Divider(height: 1, color: AppColors.divider),
            _settingTile(
              icon: Icons.info_outline,
              label: "About App",
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: hook up logout logic
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}