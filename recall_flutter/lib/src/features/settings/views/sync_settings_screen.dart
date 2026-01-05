import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/src/core/app_colors.dart';
import '../../home/providers/dashboard_provider.dart';

class SyncSettingsScreen extends ConsumerWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final isSyncing = dashboardState.data?.isSyncing ?? false;
    final lastSync = dashboardState.data?.lastSyncTime;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Gmail Sync', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSyncing ? AppColors.primary : Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isSyncing ? AppColors.primary : const Color(0xFF34D399)).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSyncing ? Icons.sync : Icons.check_circle,
                      size: 32,
                      color: isSyncing ? AppColors.primary : const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSyncing ? 'Syncing...' : 'System Operational',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastSync != null ? 'Last synced: ${_formatDate(lastSync)}' : 'No sync history',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('ACTIONS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 16),
            
            _ActionTile(
              title: 'Sync Now',
              subtitle: 'Manually trigger a Gmail analysis',
              icon: Icons.refresh,
              color: AppColors.primary,
              isLoading: isSyncing,
              onTap: () {
                 ref.read(dashboardProvider.notifier).refresh();
              },
            ),
            const SizedBox(height: 16),
            _ActionTile(
              title: 'Disconnect Gmail',
              subtitle: 'Stop analyzing emails. Data remains.',
              icon: Icons.link_off,
              color: Colors.redAccent,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.month}/${date.day}";
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 color: color.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: isLoading 
                 ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: color, strokeWidth: 2))
                 : Icon(icon, color: color, size: 24),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                   const SizedBox(height: 4),
                   Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                 ],
               ),
             ),
             const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
