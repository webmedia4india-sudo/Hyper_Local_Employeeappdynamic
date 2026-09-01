import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

/// Types of notifications shown on this page.
enum NotifType { application, interview, message, payment, system }

class NotificationItem {
  final String id;
  final NotifType type;
  final String title;
  final String message;
  final String time;
  final String group; // "Today" | "Yesterday" | "Earlier"
  bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.group,
    this.isRead = false,
  });
}

class EmployeeNotificationPage extends StatefulWidget {
  const EmployeeNotificationPage({super.key});

  @override
  State<EmployeeNotificationPage> createState() =>
      _EmployeeNotificationPageState();
}

class _EmployeeNotificationPageState extends State<EmployeeNotificationPage>
    with TickerProviderStateMixin {
  // ── Dummy data — replace with API/DB data ──
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotifType.application,
      title: 'New application received',
      message: 'Rohit Sharma applied for "Flutter Developer".',
      time: '10 min ago',
      group: 'Today',
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      type: NotifType.interview,
      title: 'Interview scheduled',
      message: 'Interview with Sneha Patil set for 4:00 PM today.',
      time: '1 hr ago',
      group: 'Today',
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      type: NotifType.message,
      title: 'New message',
      message: 'HR Manager Priya sent you a message.',
      time: '3 hr ago',
      group: 'Today',
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      type: NotifType.payment,
      title: 'Subscription renewed',
      message: 'Your Pro plan was renewed successfully.',
      time: 'Yesterday, 6:20 PM',
      group: 'Yesterday',
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      type: NotifType.system,
      title: 'Profile update reminder',
      message: 'Complete your company profile to get more visibility.',
      time: 'Yesterday, 11:05 AM',
      group: 'Yesterday',
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      type: NotifType.application,
      title: 'Application shortlisted',
      message: 'You shortlisted Aman Verma for "UI/UX Designer".',
      time: '2 days ago',
      group: 'Earlier',
      isRead: true,
    ),
  ];

  // Controls the staggered entrance animation for the whole list.
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _toggleRead(NotificationItem item) {
    if (item.isRead) return;
    setState(() => item.isRead = true);
  }

  // Curved, delayed animation for the item at [index] — creates the
  // staggered "cascade" entrance effect.
  Animation<double> _itemAnimation(int index) {
    final start = (index * 0.08).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _listController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  // ── Type → (icon, color) mapping ──
  (IconData, Color, Color) _styleFor(NotifType type) {
    switch (type) {
      case NotifType.application:
        return (Icons.description_rounded, AppColors.primary, AppColors.accentsSoft[0]);
      case NotifType.interview:
        return (Icons.event_available_rounded, AppColors.mint, AppColors.mintSoft);
      case NotifType.message:
        return (Icons.chat_bubble_rounded, AppColors.coral, AppColors.coralSoft);
      case NotifType.payment:
        return (Icons.payments_rounded, AppColors.pink, AppColors.pinkSoft);
      case NotifType.system:
        return (Icons.info_rounded, AppColors.lime, AppColors.limeSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group notifications while preserving insertion order of groups.
    final Map<String, List<NotificationItem>> grouped = {};
    for (final n in _notifications) {
      grouped.putIfAbsent(n.group, () => []).add(n);
    }

    int itemIndex = 0; // running index used for stagger timing

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
          "Notifications",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SizeTransition(
                sizeFactor: anim,
                axis: Axis.horizontal,
                child: child,
              ),
            ),
            child: _unreadCount > 0
                ? TextButton(
                    key: const ValueKey('markAllBtn'),
                    onPressed: _markAllRead,
                    child: const Text(
                      "Mark all read",
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('noBtn'), width: 4),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _notifications.isEmpty
            ? _EmptyState(
                key: const ValueKey('empty'),
                onRefresh: () => setState(() {}),
              )
            : ListView(
                key: const ValueKey('list'),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SizeTransition(sizeFactor: anim, child: child),
                    ),
                    child: _unreadCount > 0
                        ? Padding(
                            key: ValueKey('badge_$_unreadCount'),
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "$_unreadCount new",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('noBadge')),
                  ),
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) {
                      final animation = _itemAnimation(itemIndex);
                      itemIndex++;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StaggeredEntry(
                          animation: animation,
                          child: Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _dismissNotification(item.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            child: _NotificationTile(
                              item: item,
                              style: _styleFor(item.type),
                              onTap: () => _toggleRead(item),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Wraps a child with a fade + slide-up "cascade" entrance animation.
class _StaggeredEntry extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _StaggeredEntry({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 24),
            child: child,
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final (IconData, Color, Color) style;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, accent, accentSoft) = style;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead ? AppColors.border : accent.withValues(alpha: 0.35),
            width: item.isRead ? 1 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: item.isRead ? 0.03 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.w700,
                          ),
                          child: Text(item.title),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: item.isRead
                            ? const SizedBox(key: ValueKey('noDot'))
                            : Padding(
                                key: const ValueKey('dot'),
                                padding: const EdgeInsets.only(left: 8, top: 3),
                                child: _PulsingDot(color: accent),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small dot that gently pulses to draw the eye toward unread items.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _EmptyState extends StatefulWidget {
  final VoidCallback onRefresh;

  const _EmptyState({super.key, required this.onRefresh});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.accentsSoft[0],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeTransition(
              opacity: _fade,
              child: const Text(
                "No notifications yet",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeTransition(
              opacity: _fade,
              child: const Text(
                "You're all caught up! New updates about\n"
                "jobs, candidates and interviews will show here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fade,
              child: TextButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                label: const Text(
                  "Refresh",
                  style: TextStyle(
                    color: AppColors.primary,
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
}