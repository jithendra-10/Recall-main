import 'package:recall_flutter/src/features/home/views/widgets/email_composer_sheet.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/src/core/app_colors.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/src/features/auth/controllers/auth_controller.dart';
import 'package:recall_flutter/main.dart';
import 'package:recall_client/src/protocol/dashboard_data.dart';
import 'package:recall_client/src/protocol/interaction_summary.dart';
import 'package:recall_client/src/protocol/contact.dart';
import '../providers/dashboard_provider.dart';
import '../../../services/connectivity_provider.dart';
import 'coming_soon_screen.dart';
import 'ask_recall_screen.dart';
import '../../settings/views/settings_screen.dart';
import 'package:recall_flutter/src/features/auth/views/sign_in_screen.dart';
import '../../network/views/network_screen.dart';
import '../../notifications/views/notification_screen.dart';
import '../../agenda/views/agenda_screen.dart';
import '../../audio/views/voice_recording_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  
  // Compose Logic State
  bool _isComposing = false; // Used for UI visibility
  bool _isSending = false;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Get user info logic
  String get _userFirstName {
    if (currentGoogleUser?.displayName != null) {
      return currentGoogleUser!.displayName!.split(' ').first;
    }
    if (storedUserInfo?.name != null) {
      return storedUserInfo!.name!.split(' ').first;
    }
    return sessionManager.signedInUser?.fullName?.split(' ').first ?? 'User';
  }

  String? get _userImageUrl {
    return currentGoogleUser?.photoUrl ?? 
           storedUserInfo?.photo ?? 
           sessionManager.signedInUser?.imageUrl;
  }

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    // Give time for UI to build
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    try {
      final status = await client.dashboard.getSetupStatus();
      if (!status.hasToken) {
        // We are logged in locally but server doesn't have the token (likely due to previous port error)
        if (mounted) {
           // Just warn, don't logout automatically as it causes loops
           print('Warning: Server reporting missing token');
        }
      }
    } catch (e) {
      print('Dashboard connection check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            userFirstName: _userFirstName,
            userImageUrl: _userImageUrl,
          ),
          const AskRecallScreen(),
          const NetworkScreen(),
          const AgendaScreen(), // Index 3
        ],
      ),
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onVoiceNotePressed: _onVoiceNotePressed,
      ),
    );
  }

  Future<void> _onVoiceNotePressed() async {
    final transcript = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceRecordingSheet(),
    );

    if (transcript != null && transcript.isNotEmpty) {
      if (!mounted) return;
      // TODO: Process voice note with server
      // For now, simple interaction or send to chat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing: "$transcript"...')),
      );
      
      // Sending to chat as user message for now to test flow
      // In next step, we will call specialized endpoint
      final result = await ref.read(dashboardProvider.notifier).processVoiceNote(transcript);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      // Optionally switch to Agenda if relevant
      // setState(() => _currentIndex = 1);
    }
  }
}

// ============================================================================
// HOME TAB
// ============================================================================
// ============================================================================
// HOME TAB
// ============================================================================
class _HomeTab extends ConsumerWidget {
  final String userFirstName;
  final String? userImageUrl;

  const _HomeTab({
    required this.userFirstName,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final isLoading = dashboardState.isLoading;
    final isSyncing = dashboardState.data?.isSyncing ?? false;
    final showLoadingOverlay = isLoading && dashboardState.data == null;
    final isOffline = !connectivityState.isConnected;

    return SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            color: AppColors.primary,
            backgroundColor: AppColors.backgroundDark,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120), // Space for floating nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: _PremiumHeader(
                      firstName: userFirstName,
                      imageUrl: userImageUrl,
                      driftingCount: dashboardState.data?.driftingCount ?? 0,
                      isOffline: isOffline,
                    ),
                  ),

                  // Offline Banner
                  if (isOffline)
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF1F2937), // Dark grey
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                           Icon(Icons.wifi_off, size: 14, color: Colors.amberAccent),
                           SizedBox(width: 8),
                           Text(
                            'Offline Mode',
                            style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),

                  if (dashboardState.data != null)
                    _DashboardContent(
                      data: dashboardState.data!,
                      onDraftPressed: (contact) => _showDraftComposer(context, ref, contact),
                    )
                  else if (dashboardState.isLoading)
                    const _LoadingState(),
                ],
              ),
            ),
          ),

          // Blur Overlay & Loading Bar
          if (showLoadingOverlay)
            Positioned.fill(
              child: Stack(
                children: [
                   // Blur Effect
                   BackdropFilter(
                    filter: dart_ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                   ),
                   const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showDraftComposer(BuildContext context, WidgetRef ref, Contact contact) async {
    // 1. Show Loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating smart draft with AI...')),
    );

    try {
      // 2. Fetch Draft
      final draftBody = await ref.read(draftEmailProvider(contact.id!).future);
      
      if (!context.mounted) return;

      // 3. Open Composer Sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => EmailComposerSheet(
          contact: contact,
          initialBody: draftBody,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to generate draft: $e')),
        );
      }
    }
  }
}
// ============================================================================
// EMAIL COMPOSER SHEET
// ============================================================================


class _DashboardContent extends StatelessWidget {
  final DashboardData data;
  final Function(Contact) onDraftPressed;

  const _DashboardContent({required this.data, required this.onDraftPressed});

  @override
  Widget build(BuildContext context) {
    final hasNudge = data.nudgeContact != null;
    final hasInteractions = data.recentInteractions.isNotEmpty;

    return Column(
      children: [
        if (hasNudge)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _DriftingHighlightCard(
              contact: data.nudgeContact!,
              daysSilent: data.nudgeDaysSilent ?? 0,
              lastTopic: data.nudgeLastTopic,
              onDraftPressed: onDraftPressed,
            ),
          ),
          
        const SizedBox(height: 32),
        
        const SizedBox(height: 32),
        
        // Recent Memories Section (Always show to inform user)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Text(
                'Recent Memories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              if (hasInteractions) ...[
                 const Spacer(),
                 Text(
                   'AI Summaries',
                   style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                 ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        if (hasInteractions)
          _ContextCarousel(interactions: data.recentInteractions)
        else
          const _EmptyContextState(),
          
        const SizedBox(height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _NetworkHealthCard(
            totalContacts: data.totalContacts ?? 0,
            driftingCount: data.driftingCount ?? 0,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PREMIUM HEADER
// ============================================================================
class _PremiumHeader extends StatelessWidget {
  final String firstName;
  final String? imageUrl;
  final int driftingCount;
  final bool isOffline;

  const _PremiumHeader({
    super.key,
    required this.firstName,
    this.imageUrl,
    required this.driftingCount,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Space Grotesk', // Ensure font is responsive if missed
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'Good Morning,\n'),
                  TextSpan(
                    text: '$firstName.',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'You have '),
                  TextSpan(
                    text: '$driftingCount relationships',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' drifting.'),
                ],
              ),
            ),
          ],
        ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  margin: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Settings
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                    ),
                    child: Stack(
                      children: [
                        imageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  width: 48,
                                  height: 48,
                                ),
                              )
                            : const Center(child: Icon(Icons.person, color: Colors.white)),
                        
                        // Status Dot
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isOffline ? Colors.grey : AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.backgroundDark, width: 2),
                              boxShadow: [
                                if (!isOffline)
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }
}

// ============================================================================
// DRIFTING HIGHLIGHT CARD (GLOWING)
// ============================================================================
class _DriftingHighlightCard extends StatelessWidget {
  final Contact contact;
  final int daysSilent;
  final String? lastTopic;
  final Function(Contact) onDraftPressed;

  const _DriftingHighlightCard({
    required this.contact,
    required this.daysSilent,
    this.lastTopic,
    required this.onDraftPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 242, 250, 0.2), // Cyan glow
            blurRadius: 20,
            spreadRadius: -5,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Liquid blur
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08), // Glassy background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.surfaceDark,
                        backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
                        child: contact.avatarUrl == null
                            ? Text(contact.name?[0] ?? '?', style: const TextStyle(fontSize: 24, color: Colors.white))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name ?? contact.email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              '$daysSilent days silent',
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lastTopic ?? 'Time to reconnect...',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onDraftPressed(contact),
                    icon: const Icon(Icons.edit_note, color: Colors.black),
                    label: const Text('Draft Catch-up Email', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CONTEXT CAROUSEL
// ============================================================================
class _ContextCarousel extends StatelessWidget {
  final List<InteractionSummary> interactions;

  const _ContextCarousel({required this.interactions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 300, // Increased height to fix overflow
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: const [
             BoxShadow(
              color: Colors.black26, 
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ListView.separated(
              padding: const EdgeInsets.all(20), // Internal padding
              scrollDirection: Axis.horizontal,
              itemCount: interactions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = interactions[index];
                final dateStr = DateFormat('MMM d, h:mm a').format(item.timestamp.toLocal());
                
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surfaceDark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white.withOpacity(0.1))),
                        title: Text(item.contactName, style: const TextStyle(color: Colors.white)),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.summary,
                                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 260, // Slightly smaller to fit
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    item.contactName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mail_outline, color: AppColors.textSecondary, size: 16),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: index % 2 == 0 ? AppColors.primary : AppColors.secondary, 
                                width: 2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RECALL',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.summary,
                                style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 13, height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NETWORK HEALTH CARD
// ============================================================================
class _NetworkHealthCard extends StatelessWidget {
  final int totalContacts;
  final int driftingCount;

  const _NetworkHealthCard({
    required this.totalContacts,
    required this.driftingCount,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dummy score if no contacts, else simple math
    final score = totalContacts > 0 
        ? ((totalContacts - driftingCount) / totalContacts * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Network Health',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Your connectivity\nscore is trending up.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
              ),
            ],
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: AppColors.secondary,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '$score%',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyContextState extends StatelessWidget {
  const _EmptyContextState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analyzing your history...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recall is reading your emails to generate smart summaries of your relationships.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREMIUM BOTTOM NAV
// ============================================================================
class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onVoiceNotePressed;

  const _PremiumBottomNav({
    required this.currentIndex, 
    required this.onTap,
    required this.onVoiceNotePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1F24),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea( 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BottomNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              isSelected: currentIndex == 0,
              isPrimary: true,
              onTap: () => onTap(0),
            ),
            _BottomNavItem(
              icon: Icons.chat_bubble,
              label: 'Chat',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            GestureDetector(
              onTap: onVoiceNotePressed,
              child: Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 28),
              ),
            ),
            _BottomNavItem(
              icon: Icons.group,
              label: 'People',
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _BottomNavItem(
              icon: Icons.calendar_month,
              label: 'Agenda',
              isSelected: currentIndex == 3, 
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }

}

// Add the floating mic button using an Overlay or Stack in the main scaffold if needed, 
// For now, I'll rely on the design having a central button look.
// Actually, standard BottomNavigationBar can't easily support the "overflow" button shown in design.
// I will implement a custom layout. 
// ============================================================================
// EXTENDED UI HELPERS
// ============================================================================
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isPrimary;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: isSelected 
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXTENDED UI HELPERS
// ============================================================================
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

extension BorderSideExt on Border {
  static Border l({Color color = Colors.white, double width = 1.0}) {
     return Border(left: BorderSide(color: color, width: width));
  }
}
