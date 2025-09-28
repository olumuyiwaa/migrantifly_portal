// dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../api/api_get.dart';
import '../constants.dart';
import '../controllers/menu_app_controller.dart';
import '../models/class_notifications.dart';
import '../responsive.dart';

class Header extends StatefulWidget {
  final String title;

  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  const Header({
    Key? key,
    required this.title,
    required this.onItemTapped,
    required this.onTitleTapped,
  }) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  void _openNotificationsDrawer() {
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = width < 500 ? width * 0.9 : 360.0;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: drawerWidth,
              height: double.infinity,
              child: const _NotificationsDrawer(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnim = Tween<Offset>(
          begin: const Offset(1, 0), // slide in from right
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        return SlideTransition(position: offsetAnim, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                "assets/icons/${widget.title.toLowerCase()}.svg",
                color: Colors.grey,
                height: 24,
              ),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
        if (!Responsive.isMobile(context)) const SizedBox(width: 12),
        const Expanded(child: SearchField()),
        const SizedBox(width: defaultPadding),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),padding: EdgeInsetsGeometry.all(12),
          icon: const Icon(Icons.notifications_rounded, color: Colors.black87,),
          onPressed: _openNotificationsDrawer,
        )
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsDrawer extends StatefulWidget {
  const _NotificationsDrawer();

  @override
  State<_NotificationsDrawer> createState() => _NotificationsDrawerState();
}

class _NotificationsDrawerState extends State<_NotificationsDrawer> {
  List<NotificationModel> notifications = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchAllNotifications();
  }

  Future<void> _fetchAllNotifications() async {
    if (mounted) setState(() => isLoading = true);
    try {
      notifications = await loadCachedNotifications();
      if (mounted && notifications.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
      }
      final freshNotifications = await fetchNotifications();
      await cacheNotifications(freshNotifications);

      if (mounted) {
        setState(() {
          notifications = freshNotifications;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading Notification: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Material(
        color: Colors.white,
        elevation: 8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.06),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_rounded, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Mark all as read',
                    onPressed: () {
                      // Implement mark-all-as-read behavior
                      Navigator.of(context).pop(); // Optional: close after action
                    },
                    icon: const Icon(Icons.done_all_rounded),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Notifications list
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              ): notifications.isEmpty
                  ? const Center(
                child: Text('No notifications'),
              )
                  : ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: n.isRead
                          ? Colors.grey.shade200
                          : primaryColor.withOpacity(0.12),
                      child: Icon(
                        n.isRead ? Icons.notifications_none : Icons.notifications,
                        color: n.isRead ? Colors.grey.shade700 : primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      n.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    trailing: Text(
                      _timeAgo(n.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onTap: () {
                      // Handle tap on a notification (navigate, etc.)
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
