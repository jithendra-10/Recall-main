import 'package:flutter/material.dart';
import 'package:recall_flutter/src/core/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Privacy & Security', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Security Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF34D399).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 48, color: Color(0xFF34D399)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data Encrypted', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'Your relationship data is encrypted at rest and in transit.',
                        style: TextStyle(color: const Color(0xFF34D399).withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          const _SectionHeader('DATA MANAGEMENT'),
          const SizedBox(height: 16),
          
          _MenuTile(icon: Icons.download, title: 'Export My Data', onTap: () {}),
          _MenuTile(icon: Icons.history, title: 'Clear History', onTap: () {}),
          _MenuTile(icon: Icons.password, title: 'Change Password', subtitle: 'Managed via Google', onTap: () {}, isEnabled: false),
          
          const SizedBox(height: 32),
          const _SectionHeader('LEGAL'),
          const SizedBox(height: 16),
           _MenuTile(icon: Icons.description, title: 'Terms of Service', onTap: () {}),
           _MenuTile(icon: Icons.privacy_tip, title: 'Privacy Policy', onTap: () {}),
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isEnabled;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListTile(
          onTap: isEnabled ? onTap : null,
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)) : null,
          trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
      ),
    );
  }
}
