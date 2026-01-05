import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/src/core/app_colors.dart';
import 'package:recall_flutter/main.dart'; // For user session
import 'package:recall_flutter/src/features/auth/controllers/auth_controller.dart';
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart' hide AppColors;

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = sessionManager.signedInUser;
    final googleUser = currentGoogleUser;

    final name = googleUser?.displayName ?? user?.fullName ?? 'User';
    final email = googleUser?.email ?? user?.email ?? 'No email';
    final imageUrl = googleUser?.photoUrl ?? user?.imageUrl;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                      image: imageUrl != null 
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: imageUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white54) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Fields
            _InfoField(label: 'Full Name', value: name, icon: Icons.person_outline),
            const SizedBox(height: 16),
            _InfoField(label: 'Email Address', value: email, icon: Icons.email_outlined),
            const SizedBox(height: 16),
             _InfoField(label: 'User ID', value: '${user?.id ?? "Unknown"}', icon: Icons.fingerprint),
         
            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Danger Zone
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DANGER ZONE',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deleting your account will permanently remove all your data, including relationship history and context.',
                    style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement delete account flow
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      side: const BorderSide(color: Colors.red, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Delete Account'),
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

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoField({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
