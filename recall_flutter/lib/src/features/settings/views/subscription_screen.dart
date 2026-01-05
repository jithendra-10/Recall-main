import 'package:flutter/material.dart';
import 'package:recall_flutter/src/core/app_colors.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Subscription', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
            // Pro Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo to Purple
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PRO PLAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                     'Unlimited Access',
                     style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Next billing date: Jan 20, 2026',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features
            const _SectionHeader('YOUR FEATURES'),
            const SizedBox(height: 16),
            _FeatureTile(icon: Icons.all_inclusive, title: 'Unlimited Contacts'),
            _FeatureTile(icon: Icons.psychology, title: 'Advanced AI Analysis'),
            _FeatureTile(icon: Icons.history, title: 'Unlimited History'),
            _FeatureTile(icon: Icons.cloud_sync, title: 'Priority Gmail Sync'),
            
            const SizedBox(height: 32),
            
            // Manage Subscription
             SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Manage Subscription'),
              ),
             ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.purpleAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.check, color: Color(0xFF34D399), size: 18),
        ],
      ),
    );
  }
}
