import 'package:flutter/material.dart';

class CandidateProfilePage extends StatelessWidget {
  final Map<String, dynamic> candidate;

  const CandidateProfilePage({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final String name = candidate['name'] as String? ?? 'Candidate Profile';
    final String role = candidate['role'] as String? ?? candidate['current_role'] as String? ?? 'Job Candidate';
    final String industry = candidate['industry'] as String? ?? 'General Industry';
    final String email = candidate['email'] as String? ?? '';
    final String address = candidate['address'] as String? ?? 'Amravati, Maharashtra';
    final String distance = candidate['distance'] as String? ?? 'Nearby';
    final String rating = candidate['rating'] as String? ?? '4.8';
    final Color themeColor = candidate['color'] as Color? ?? const Color(0xFF1E3AE2);
    final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3AE2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Candidate Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Candidate profile saved!')),
              );
            },
            icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── TOP ROYAL BLUE PROFILE HEADER ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3AE2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: themeColor,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      industry,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── HIGHLIGHT STATS ROW ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard("Rating", "$rating ⭐", Icons.star_rounded, const Color(0xFFFFB300)),
                  const SizedBox(width: 10),
                  _buildStatCard("Distance", distance, Icons.near_me_rounded, const Color(0xFF1E3AE2)),
                  const SizedBox(width: 10),
                  _buildStatCard("Experience", "0-2 Yrs", Icons.work_history_rounded, const Color(0xFF10B981)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── CONTACT & LOCATION DETAILS CARD (NO CALL BUTTON) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Location & Information",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Divider(height: 20),
                    if (email.isNotEmpty)
                      _buildInfoRow(Icons.email_rounded, "Email Address", email, const Color(0xFF0284C7)),
                    if (email.isNotEmpty) const SizedBox(height: 12),
                    _buildInfoRow(Icons.location_on_rounded, "Current Address", address, const Color(0xFFEF4444)),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.badge_rounded, "Industry Sector", industry, const Color(0xFF8B5CF6)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── JOB PREFERENCES & SKILLS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Job Preferences & Skills",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Divider(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSkillChip(role),
                        _buildSkillChip(industry),
                        _buildSkillChip("Full-Time"),
                        _buildSkillChip("Immediate Joiner"),
                        _buildSkillChip("Verified Profile"),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Candidate Overview",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Active candidate seeking opportunities in $role ($industry) domain around $address. Verified active job seeker in nearby radius.",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── FIXED BOTTOM ACTION BAR (NO CALL BUTTON) ──
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Interview invitation sent to $name!')),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text(
              "Hire / Invite Candidate",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3AE2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF334155),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
