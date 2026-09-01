import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationpage.dart';
import 'package:hyper_local_employee/Pages/employeechatspage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TapScale({super.key, required this.child, this.onTap});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  double _scale = 1.0;

  void _setScale(double v) => setState(() => _scale = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.94),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class EmployeeMessagePage extends StatefulWidget {
  const EmployeeMessagePage({super.key});

  @override
  State<EmployeeMessagePage> createState() => _EmployeeMessagePageState();
}

class _EmployeeMessagePageState extends State<EmployeeMessagePage> {
  // bottom dock — "Chat" tab is active on this page
  int _selectedIndex = 3;

  int _selectedFilter = 0; // 0 = All, 1 = Unread, 2 = Archived
  String _searchQuery = "";

  final List<_ChatItem> _chats = const [
    _ChatItem(
      name: "Rahul Verma",
      message: "Hi Sir, I can join from Monday.",
      time: "11:30 AM",
      unreadCount: 2,
    ),
    _ChatItem(
      name: "Sunil Yadev",
      message: "Call ended",
      time: "10:15 AM",
      unreadCount: 0,
    ),
    _ChatItem(
      name: "Amit Singh",
      message: "Interview details shared",
      time: "Yesterday",
      unreadCount: 0,
    ),
    _ChatItem(
      name: "Vikas Pawar",
      message: "Thanks for the update",
      time: "Yesterday",
      unreadCount: 0,
    ),
    _ChatItem(
      name: "Support Team",
      message: "How can we help you?",
      time: "12 May",
      unreadCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredChats = _chats.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.message.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_selectedFilter == 1) return c.unreadCount > 0; // Unread
      // (Archived has no data source yet — shows empty state for now)
      if (_selectedFilter == 2) return false;
      return true;
    }).toList();

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
          "Messages",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // ── Search bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: "Search messages",
                          hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13.5),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  // ── Filter tabs (All / Unread / Archived) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Row(
                      children: [
                        _buildFilterTab("All", 0),
                        const SizedBox(width: 20),
                        _buildFilterTab("Unread", 1),
                        const SizedBox(width: 20),
                        _buildFilterTab("Archived", 2),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Chat list ──
                  Expanded(
                    child: filteredChats.isEmpty
                        ? Center(
                            child: Text(
                              "No messages found",
                              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            itemCount: filteredChats.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              indent: 78,
                              color: AppColors.divider,
                            ),
                            itemBuilder: (context, index) {
                              final chat = filteredChats[index];
                              final avatarColor =
                                  AppColors.accentsSoft[index % AppColors.accentsSoft.length];
                              final avatarTextColor =
                                  AppColors.accents[index % AppColors.accents.length];

                              return InkWell(
                                onTap: () {
                                  // Open the chat conversation for this person
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EmployeeChatsPage(
                                        name: chat.name,
                                        avatarColor: avatarColor,
                                        avatarTextColor: avatarTextColor,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: avatarColor,
                                        child: Text(
                                          chat.name.trim().isNotEmpty ? chat.name.trim()[0].toUpperCase() : "?",
                                          style: GoogleFonts.poppins(
                                            color: avatarTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chat.name,
                                              style: GoogleFonts.poppins(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              chat.message,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                color: AppColors.textSecondary,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            chat.time,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textHint,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (chat.unreadCount > 0)
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                              child: Center(
                                                child: Text(
                                                  "${chat.unreadCount}",
                                                  style: GoogleFonts.poppins(
                                                    color: AppColors.buttonText,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            _buildBottomDock(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, int index) {
    final bool isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM DOCK NAVIGATION BAR (same style as Dashboard) ──
  Widget _buildBottomDock() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockItem(Icons.home_rounded, "Home", 0, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeDashboardPage()),
                );
              }),
              _buildDockItem(Icons.work_outline_rounded, "Jobs", 1, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllJobsPage()),
                );
              }),
              _buildDockItem(Icons.assignment_outlined, "Applications", 2, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeApplicationPage()),
                );
              }),
              _buildDockItem(Icons.chat_bubble_outline_rounded, "Chat", 3, onTap: () {
                // already on Chat page
              }),
              _buildDockItem(Icons.more_horiz_rounded, "More", 4, onTap: () {
                // TODO: navigate to More/Settings page
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData icon, String label, int index, {required VoidCallback onTap}) {
    final bool isActive = _selectedIndex == index;
    final Color color = isActive ? AppColors.primary : AppColors.unselected;

    return Expanded(
      child: TapScale(
        onTap: () {
          setState(() => _selectedIndex = index);
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatItem {
  final String name;
  final String message;
  final String time;
  final int unreadCount;

  const _ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
  });
}