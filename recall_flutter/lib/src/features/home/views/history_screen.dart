import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/src/features/home/providers/dashboard_provider.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/src/core/app_colors.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now().toLocal();
    final localDate = date.toLocal();
    final diff = now.difference(localDate);
    
    if (diff.inDays == 0 && localDate.day == now.day) {
      return 'Today';
    } else if (diff.inDays <= 1 && localDate.day == now.day - 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${localDate.day}/${localDate.month}/${localDate.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final sessions = chatState.sessions;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: sessions.isEmpty
          ? Center(
              child: Text(
                'No past conversations.',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isActive = session.id == chatState.activeSessionId;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      ref.read(chatProvider.notifier).selectSession(session.id!);
                      Navigator.pop(context); // Return to Chat Screen
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? AppColors.primary.withOpacity(0.15) 
                            : const Color(0xFF252B33),
                        borderRadius: BorderRadius.circular(12),
                        border: isActive 
                            ? Border.all(color: AppColors.primary.withOpacity(0.5)) 
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: isActive ? AppColors.primary : Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title ?? 'Conversation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(session.updatedAt ?? DateTime.now()),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
