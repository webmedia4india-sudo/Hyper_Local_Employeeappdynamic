import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

// TODO: adjust this import path to match your project structure

/// Simple model for the candidate being viewed.
/// Wire this up to your real API/model later — for now it carries
/// the sample data shown in the design.
class CandidateResume {
  final String name;
  final String role;
  final String location;
  final int matchPercent;
  final String experience;
  final String noticePeriod;
  final String availability;
  final String expectedCtc;
  final String phone;
  final String email;
  final String address;
  final List<String> skills;
  final String degree;
  final String university;
  final String gradYear;
  final String jobTitle;
  final String company;
  final String duration;
  final String jobDescription;
  final String resumeFileName;

  const CandidateResume({
    this.name = "Rohit Sharma",
    this.role = "Flutter Developer",
    this.location = "Nagpur, MH",
    this.matchPercent = 92,
    this.experience = "3 Years",
    this.noticePeriod = "Immediate",
    this.availability = "Full-time",
    this.expectedCtc = "6-8 LPA",
    this.phone = "+91 98765 43210",
    this.email = "rohit.sharma@email.com",
    this.address = "Dharampeth, Nagpur",
    this.skills = const ["Flutter", "Dart", "Firebase"],
    this.degree = "B.Tech - Computer Science",
    this.university = "RTMNU, Nagpur",
    this.gradYear = "2021",
    this.jobTitle = "Flutter Developer",
    this.company = "TechNova Pvt. Ltd.",
    this.duration = "Jan 2023 - Present",
    this.jobDescription =
        "Built and maintained cross-platform mobile apps using Flutter.",
    this.resumeFileName = "resume_rohit.pdf",
  });
}

class EmployeeViewResumePage extends StatelessWidget {
  final CandidateResume candidate;

  const EmployeeViewResumePage({
    super.key,
    this.candidate = const CandidateResume(),
  });

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
          "Candidate Profile",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _ProfileHeaderCard(candidate: candidate),
          const SizedBox(height: 16),
          _StatsGrid(candidate: candidate),
          const SizedBox(height: 24),
          const _SectionTitle(icon: Icons.description_outlined, title: "Contact Information"),
          const SizedBox(height: 12),
          _ContactInfoCard(candidate: candidate),
          const SizedBox(height: 24),
          const _SectionTitle(icon: Icons.code, title: "Skills & Technology"),
          const SizedBox(height: 12),
          _SkillsWrap(skills: candidate.skills),
          const SizedBox(height: 24),
          const _SectionTitle(icon: Icons.school_outlined, title: "Education"),
          const SizedBox(height: 12),
          _EducationCard(candidate: candidate),
          const SizedBox(height: 24),
          const _SectionTitle(icon: Icons.work_outline, title: "Work Experience"),
          const SizedBox(height: 12),
          _WorkExperienceTile(candidate: candidate),
          const SizedBox(height: 24),
          const _SectionTitle(icon: Icons.insert_drive_file_outlined, title: "Attached Resume"),
          const SizedBox(height: 12),
          _ResumeFileCard(fileName: candidate.resumeFileName),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        onReject: () {
          // TODO: hook up reject action
        },
        onShortlist: () {
          // TODO: hook up shortlist action
        },
      ),
    );
  }
}

// ─────────────────────────────── HEADER CARD ───────────────────────────────

class _ProfileHeaderCard extends StatelessWidget {
  final CandidateResume candidate;
  const _ProfileHeaderCard({required this.candidate});

  String get _initials {
    final parts = candidate.name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  candidate.role,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.white.withOpacity(0.85), size: 15),
                    const SizedBox(width: 4),
                    Text(
                      candidate.location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: Colors.white, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        "${candidate.matchPercent}% Match",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── STATS GRID ───────────────────────────────

class _StatsGrid extends StatelessWidget {
  final CandidateResume candidate;
  const _StatsGrid({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.work_outline, "Experience", candidate.experience),
      (Icons.event_available_outlined, "Notice Period", candidate.noticePeriod),
      (Icons.access_time, "Availability", candidate.availability),
      (Icons.currency_rupee, "Expected CTC", candidate.expectedCtc),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: stats.map((s) => _StatCard(icon: s.$1, label: s.$2, value: s.$3)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── SECTION TITLE ───────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryDeep),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────── CONTACT CARD ───────────────────────────────

class _ContactInfoCard extends StatelessWidget {
  final CandidateResume candidate;
  const _ContactInfoCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          _ContactRow(icon: Icons.phone_outlined, label: "Phone", value: candidate.phone),
          const Divider(height: 20, color: AppColors.divider),
          _ContactRow(icon: Icons.mail_outline, label: "Email", value: candidate.email),
          const Divider(height: 20, color: AppColors.divider),
          _ContactRow(icon: Icons.home_outlined, label: "Address", value: candidate.address),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────── SKILLS ───────────────────────────────

class _SkillsWrap extends StatelessWidget {
  final List<String> skills;
  const _SkillsWrap({required this.skills});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(skills.length, (i) {
        final Color fg = AppColors.accents[i % AppColors.accents.length];
        final Color bg = AppColors.accentsSoft[i % AppColors.accentsSoft.length];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            skills[i],
            style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────── EDUCATION ───────────────────────────────

class _EducationCard extends StatelessWidget {
  final CandidateResume candidate;
  const _EducationCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.degree,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  candidate.university,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            candidate.gradYear,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── WORK EXPERIENCE ───────────────────────────────

class _WorkExperienceTile extends StatelessWidget {
  final CandidateResume candidate;
  const _WorkExperienceTile({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                candidate.jobTitle,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${candidate.company} · ${candidate.duration}",
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                candidate.jobDescription,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────── RESUME FILE ───────────────────────────────

class _ResumeFileCard extends StatelessWidget {
  final String fileName;
  const _ResumeFileCard({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.coralSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf, color: AppColors.coral, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: open/preview the resume file
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.buttonText,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
            label: const Text("View", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── BOTTOM ACTION BAR ───────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onShortlist;
  const _BottomActionBar({required this.onReject, required this.onShortlist});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.close, size: 18),
                label: const Text("Reject", style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onShortlist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.favorite, size: 18),
                label: const Text("Shortlist", style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── HELPERS ───────────────────────────────

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}