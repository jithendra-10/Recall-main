import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/src/core/app_colors.dart';
import 'package:recall_flutter/src/features/auth/controllers/auth_controller.dart';
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart' hide AppColors; // For sign out nav
import 'account_screen.dart';
import 'subscription_screen.dart';
import 'sync_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_screen.dart';
import '../../../../main.dart'; // For sessionManager
import '../../home/providers/dashboard_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final user = sessionManager.signedInUser;
    final googleUser = currentGoogleUser;

    // Data Binding
    final name = googleUser?.displayName ?? user?.fullName ?? 'User';
    final imageUrl = googleUser?.photoUrl ?? user?.imageUrl;
    final activeNodes = dashboardState.data?.totalContacts ?? 0;
    
    // Calculate network health (simple avg for now)
    final healthScore = dashboardState.data?.driftingCount != null && activeNodes > 0
        ? ((activeNodes - dashboardState.data!.driftingCount!) / activeNodes * 100).round()
        : 100;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15), // Reduced for subtle effect
                  shape: BoxShape.circle,
                ),
              ).makeBlur(80),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Text(
                        'SETTINGS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance spacing
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Profile Section
                        Stack(
                          children: [
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                                color: AppColors.surfaceDark,
                                boxShadow: [
                                   BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                                ]
                              ),
                              child: ClipOval(
                                child: imageUrl != null 
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : const Icon(Icons.person, size: 48, color: Colors.white54),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.backgroundDark, width: 3),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8),
                                  ],
                                ),
                                child: const Icon(Icons.edit, size: 16, color: AppColors.backgroundDark),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatItem(label: 'ACTIVE NODES', value: '$activeNodes', color: AppColors.primary),
                            Container(height: 32, width: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 32)),
                            _StatItem(label: 'HEALTH', value: '$healthScore%', color: const Color(0xFF34D399), icon: Icons.monitor_heart),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Preferences Group
                        const _SectionHeader('PREFERENCES'),
                        const SizedBox(height: 12),
                        _GlassPanel(
                          children: [
                            _SettingsTile(
                              icon: Icons.manage_accounts,
                              iconColor: Colors.blue,
                              title: 'Account Details',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen())),
                            ),
                            const _Divider(),
                            _SettingsTile(
                              icon: Icons.schedule,
                              iconColor: AppColors.primary,
                              title: 'Daily Briefing Time',
                              value: '08:00 AM', // Dynamic TODO
                              onTap: () {
                                _showTimePicker(context);
                              },
                            ),
                            const _Divider(),
                            _SettingsTile(
                              icon: Icons.diamond_outlined,
                              iconColor: Colors.purpleAccent,
                              title: 'Subscription',
                              valueWidget: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  // color: Colors.purpleAccent.withOpacity(0.1),
                                  // borderRadius: BorderRadius.circular(8),
                                  // border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'PRO PLAN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: Colors.transparent, // Shader mask usually, using simple styling for now
                                    shadows: [Shadow(color: Colors.purpleAccent, offset: Offset(0,0), blurRadius: 0)],
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ).glassEffect(color: Colors.purple.withOpacity(0.1)),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // App Settings Group
                        const _SectionHeader('APP SETTINGS'),
                        const SizedBox(height: 12),
                        _GlassPanel(
                          children: [
                            _SettingsTile(
                              icon: Icons.mail_outline,
                              iconColor: Colors.redAccent,
                              title: 'Gmail Sync',
                              valueWidget: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34D399).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF34D399).withOpacity(0.2)),
                                ),
                                child: const Text(
                                  'Active (Offline)',
                                  style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncSettingsScreen())),
                            ),
                            const _Divider(),
                            _SettingsTile(
                              icon: Icons.notifications_outlined,
                              iconColor: AppColors.secondary,
                              title: 'Notifications',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
                            ),
                            const _Divider(),
                            _SettingsTile(
                              icon: Icons.shield_outlined,
                              iconColor: const Color(0xFF34D399),
                              title: 'Privacy & Security',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Sign Out
                        GestureDetector(
                          onTap: () async {
                            final auth = ref.read(authControllerProvider);
                            await auth.signOut();
                            // Navigate to Splash (which redirects to Login)
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const SplashScreen()),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.redAccent, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'RECALL V1.0.5 // SETTINGS',
                          style: TextStyle(
                             color: Colors.white24,
                             fontSize: 10,
                             letterSpacing: 2,
                             fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surfaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET HELPER CLASSES
// ============================================================================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
             color: AppColors.textSecondary,
             fontSize: 10,
             fontWeight: FontWeight.w600,
             letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final List<Widget> children;
  const _GlassPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C333A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.valueWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withOpacity(0.2)),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (valueWidget != null) valueWidget!,
            if (value == null && valueWidget == null)
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20)
            else 
               const Padding(
                 padding: EdgeInsets.only(left: 8.0),
                 child: Icon(Icons.chevron_right, color: Colors.white24, size: 20),
               ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// Extensions for visual effects
extension WidgetExt on Widget {
  Widget makeBlur(double sigma) {
    return Container(
      decoration: BoxDecoration(
         color: AppColors.primary,
         shape: BoxShape.circle,
      ),
      child: this,
    ); // Placeholder, actual blur needs BackdropFilter stack or simple DecoratedBox with BoxShadow for glow
    // For simple glow:
  }
  
  Widget glassEffect({Color? color}) {
     return this; // Placeholder for glass effect shader if needed
  }
}
