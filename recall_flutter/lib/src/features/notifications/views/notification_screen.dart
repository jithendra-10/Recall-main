import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/src/core/app_colors.dart';
import 'package:recall_flutter/src/features/home/providers/dashboard_provider.dart';

import '../../network/views/network_screen.dart' hide contactsProvider; // reusing logic if needed, but dashboard has data

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Urgent', 'Drifting', 'Birthdays'];

  @override
  Widget build(BuildContext context) {
    // We can reuse the DashboardProvider which has `nudgeContact` and basic stats
    // Or prefer contactsProvider from NetworkScreen if we want full list filtering
    // For "Intel Stream", we probably want a mix. Let's use DashboardData first.
    final dashboardState = ref.watch(dashboardProvider);
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background Elements for Atmosphere
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(200)),
              ),
              child: Image.asset('assets/images/grid_bg.png', // Fallback or mock if asset doesn't exist
                  color: AppColors.primary.withOpacity(0.05), 
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => const SizedBox(),
              ), 
            ),
          ),
          
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark.withOpacity(0.8),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Intel Stream',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Mark all read',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter), // Filter logic TODO
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(24),
                          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10)] : null,
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Notifications List
              Expanded(
                child: Builder(builder: (context) {
                   if (contactsAsync.isLoading && contactsAsync.contacts.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                   }
                   if (contactsAsync.contacts.isEmpty && contactsAsync.error != null) {
                      return Center(child: Text('Error loading intel: ${contactsAsync.error}'));
                   }
                   
                   final notifications = _generateNotifications(contactsAsync.contacts, dashboardState.data);
                    
                   if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 60, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            const Text('No new intel', style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      );
                   }

                   return ListView.separated(
                     padding: const EdgeInsets.all(24),
                     itemCount: notifications.length + 1, // +1 for "End of Stream"
                     separatorBuilder: (_, __) => const SizedBox(height: 16),
                     itemBuilder: (context, index) {
                       if (index == notifications.length) {
                         return Padding(
                           padding: const EdgeInsets.symmetric(vertical: 32),
                           child: Center(child: Text('END OF STREAM', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))),
                         );
                       }
                       return _NotificationCard(item: notifications[index]);
                     },
                   );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Generate dynamic notification items based on contacts
  List<_NotificationItem> _generateNotifications(List<Contact> contacts, DashboardData? data) {
    final items = <_NotificationItem>[];

    // 1. Drifting / Urgent (Low Health)
    final drifting = contacts.where((c) => c.healthScore < 50).toList();
    for (var c in drifting.take(3)) { // Limit to top 3
      items.add(_NotificationItem(
        type: _NotificationType.urgent,
        contact: c,
        title: c.name ?? c.email,
        message: 'Drifting Risk. Last contact: ${_getTimeSince(c.lastContacted)}.',
        timeAgo: '2h', // Mock for now, or calc difference
        icon: Icons.warning_amber_rounded,
        color: AppColors.primary,
      ));
    }

    // 2. New (Mock based on Tags or just random)
    final newContacts = contacts.where((c) => c.tags?.contains('New') ?? false).toList();
    for (var c in newContacts) {
      items.add(_NotificationItem(
        type: _NotificationType.networking,
        contact: c,
        title: 'New Connection',
        message: 'You added ${c.name} to your network.',
        timeAgo: '1d',
        icon: Icons.hub,
        color: Colors.white,
      ));
    }
    
    // 3. Follow Up (Mock based on interactions if available, or just random high health ones)
    // If we had interaction data here, we'd use it. For now, let's just pick a random high health one
    final highHealth = contacts.where((c) => c.healthScore > 80).take(1).toList();
    if (highHealth.isNotEmpty) {
       items.add(_NotificationItem(
        type: _NotificationType.followUp,
        contact: highHealth.first,
        title: highHealth.first.name ?? 'Follow Up',
        message: 'Keep the momentum going! Great relationship health.',
        timeAgo: '3h',
        icon: Icons.tips_and_updates,
        color: AppColors.secondary,
      ));
    }

    return items;
  }

  String _getTimeSince(DateTime? date) {
    if (date == null) return 'unknown';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    return 'recently';
  }
}

enum _NotificationType { urgent, birthday, followUp, networking }

class _NotificationItem {
  final _NotificationType type;
  final Contact contact;
  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color color;

  _NotificationItem({
    required this.type,
    required this.contact,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.color,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isUrgent = item.type == _NotificationType.urgent;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
        ),
        boxShadow: isUrgent 
          ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4))] 
          : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon / Avatar
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: item.color.withOpacity(0.2)),
                ),
                child: Center(
                  child: item.contact.avatarUrl != null 
                    ? ClipOval(child: Image.network(item.contact.avatarUrl!, fit: BoxFit.cover, width: 48, height: 48))
                    : Icon(item.icon, color: item.color, size: 24),
                ),
              ),
               if (isUrgent)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 4)],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        color: isUrgent ? AppColors.primary : Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Message
                Text(
                  item.message,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                
                // Urgency Actions
                if (isUrgent) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text('Draft Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                             padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                            minimumSize: const Size(0, 36),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                             foregroundColor: Colors.white60,
                          ),
                          child: const Text('Ignore', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],

                // Follow Up Action
                 if (item.type == _NotificationType.followUp) ...[
                   const SizedBox(height: 8),
                   GestureDetector(
                     onTap: () {},
                     child: Row(
                        children: [
                          Icon(Icons.send, size: 14, color: item.color),
                          const SizedBox(width: 4),
                          Text('Send Update', style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                     ),
                   )
                 ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
