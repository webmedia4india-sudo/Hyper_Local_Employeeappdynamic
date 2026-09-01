import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

/// Employer User Types Page
/// Shows Business Owner & HR Manager roles with their permissions/restrictions.
class EmployeeBusinessOwnerPage extends StatelessWidget {
  const EmployeeBusinessOwnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Employer User Types",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ── Intro text ──
          const Text(
            "Multiple Employer-Side Users",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "The platform supports multiple employer-side users, "
            "each with role-based permissions and access levels.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // ── 2.1 Business Owner ──
          RoleCard(
            roleNumber: "2.1",
            roleTitle: "Business Owner",
            roleIcon: Icons.workspace_premium_rounded,
            accentColor: AppColors.primary,
            accentSoft: const Color(0xFFE8DEFF),
            badgeText: "Full Access",
            permissions: const [
              "Manage company profile",
              "Post and edit jobs",
              "View all candidates",
              "Purchase subscriptions",
              "View payments",
              "View analytics",
              "Add team members",
              "Manage company settings",
            ],
            restrictions: const [],
          ),

          const SizedBox(height: 16),

          // ── 2.2 HR Manager ──
          RoleCard(
            roleNumber: "2.2",
            roleTitle: "HR Manager",
            roleIcon: Icons.groups_rounded,
            accentColor: AppColors.coral,
            accentSoft: AppColors.coralSoft,
            badgeText: "Limited Access",
            permissions: const [
              "Create jobs",
              "Review applications",
              "Search candidates",
              "Shortlist candidates",
              "Schedule interviews",
              "Communicate with candidates",
              "Update hiring status",
            ],
            restrictions: const [
              "Cannot change company ownership",
              "Cannot access sensitive financial settings unless permission is granted",
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable card widget for a single employer role.
class RoleCard extends StatelessWidget {
  final String roleNumber;
  final String roleTitle;
  final IconData roleIcon;
  final Color accentColor;
  final Color accentSoft;
  final String badgeText;
  final List<String> permissions;
  final List<String> restrictions;

  const RoleCard({
    super.key,
    required this.roleNumber,
    required this.roleTitle,
    required this.roleIcon,
    required this.accentColor,
    required this.accentSoft,
    required this.badgeText,
    required this.permissions,
    required this.restrictions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(roleIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$roleNumber  $roleTitle",
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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

          // ── Permissions ──
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              permissions.isEmpty ? 16 : 4,
            ),
            child: const _SectionLabel(
              text: "Permissions",
              icon: Icons.check_circle_rounded,
              color: AppColors.mint,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: permissions
                  .map(
                    (p) => _PointRow(
                      text: p,
                      icon: Icons.check_rounded,
                      iconColor: AppColors.mint,
                      iconBg: AppColors.mintSoft,
                    ),
                  )
                  .toList(),
            ),
          ),

          // ── Restrictions (only if present) ──
          if (restrictions.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: _SectionLabel(
                text: "Restrictions",
                icon: Icons.block_rounded,
                color: AppColors.error,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: restrictions
                    .map(
                      (r) => _PointRow(
                        text: r,
                        icon: Icons.close_rounded,
                        iconColor: AppColors.error,
                        iconBg: const Color(0xFFFCE4E4),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _SectionLabel({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _PointRow extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _PointRow({
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}