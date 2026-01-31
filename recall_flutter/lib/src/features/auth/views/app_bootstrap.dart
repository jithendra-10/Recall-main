import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/main.dart'; // Access sessionManager
import 'package:recall_flutter/src/features/auth/controllers/auth_controller.dart';
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart';
import 'package:recall_flutter/src/features/home/views/dashboard_screen.dart';

/// AppBootstrap handles initial session checks WITHOUT blocking the main thread.
/// It renders an empty container (white/black) matching the native splash,
/// then immediately swaps to Dashboard or SplashScreen.
class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    print("LIFECYCLE: AppBootstrap Mounted");
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // 1. Initialize Session Manager (Fast - reads SharedPrefs)
      await sessionManager.initialize();
      
      // 2. Check Login State (Optimistic)
      // If we have a session key OR the local prefs say we are logged in, go to Dashboard.
      // Dashboard will handle background recovery if the session key is actually invalid.
      final hasSession = sessionManager.isSignedIn;
      final isConceptuallyLoggedIn = await AuthController.isLoggedIn();
      
      print("Recall Bootstrap: Session=$hasSession, Prefs=$isConceptuallyLoggedIn");
      
      // CRITICAL FIX: Only auto-login if we have BOTH a session AND we believe we are logged in.
      // If Prefs=false, we explicitly logged out, so the Session is a 'ghost' that must be ignored.
      if (hasSession && isConceptuallyLoggedIn) {
        print("Recall Bootstrap: Valid Session confirmed. Launching Dashboard.");
        // Load UI helpers
        await loadStoredUserInfo(); // Static call from main.dart scope logic
        
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashboardScreen(),
            transitionDuration: Duration.zero, // Instant transition
          ),
        );
      } else {
        print("Recall Bootstrap: Not Signed In. Launching Splash.");
        // Go to custom Splash for animation
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SplashScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    } catch (e) {
      print("Recall Bootstrap Error: $e");
      // Fallback to splash on error
      if (mounted) {
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return a scaffold that matches the Native Splash background
    // to separate the "Loading Flutter" phase from "Bootstrap Logic".
    // 0xFF1A1D23 matches AppColors.backgroundDark
    return const Scaffold(
      backgroundColor: Color(0xFF1A1D23), 
      body: SizedBox.expand(), 
    );
  }
}
