import 'package:flutter/material.dart';
import 'package:recall_flutter/src/core/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _dailyBriefing = true;
  bool _driftingAlerts = true;
  bool _newMemory = true;
  bool _emailDigest = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _SectionHeader('PUSH NOTIFICATIONS'),
          const SizedBox(height: 16),
          _SwitchTile(
            title: 'Daily Briefing',
            subtitle: 'Get a morning summary of who to contact',
            value: _dailyBriefing,
            onChanged: (v) => setState(() => _dailyBriefing = v),
          ),
          _SwitchTile(
            title: 'Drifting Alerts',
            subtitle: 'Notify when a VIP contact goes silent',
            value: _driftingAlerts,
            onChanged: (v) => setState(() => _driftingAlerts = v),
          ),
          _SwitchTile(
            title: 'New Memory Detected',
            subtitle: 'When new context is found in Gmail',
            value: _newMemory,
            onChanged: (v) => setState(() => _newMemory = v),
          ),

          const SizedBox(height: 32),
          const _SectionHeader('EMAIL'),
          const SizedBox(height: 16),
          _SwitchTile(
            title: 'Weekly Digest',
            subtitle: 'Summary of your network health via email',
            value: _emailDigest,
            onChanged: (v) => setState(() => _emailDigest = v),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ),
    );
  }
}
