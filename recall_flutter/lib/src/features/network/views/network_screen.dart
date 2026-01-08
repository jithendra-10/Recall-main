import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/main.dart';
import 'package:recall_flutter/src/core/app_colors.dart';
import '../../home/providers/dashboard_provider.dart';
import 'package:recall_flutter/src/features/home/views/widgets/email_composer_sheet.dart';

class NetworkScreen extends ConsumerStatefulWidget {
  const NetworkScreen({super.key});

  @override
  ConsumerState<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends ConsumerState<NetworkScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All Contacts';
  
  final List<String> _filters = [
    'All Contacts', // Show interactions with time (ascending/descending?) User said "ascending time mails", likely meanings recent first.
    'New',          // Newly connected
    'High Health',  // Highly engaged
    'Drifting',     // Left out
  ];

  Future<void> _refresh() async {
     return ref.read(contactsProvider.notifier).refresh();
  }

  Future<void> _showDraftComposer(Contact contact) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating smart draft with AI...')),
    );

    try {
      if (contact.id == null) throw Exception("Invalid contact ID");
      final draftBody = await ref.read(draftEmailProvider(contact.id!).future);
      if (!context.mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('NETWORK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
             if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.backgroundDark,
        child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: const Icon(Icons.mic, color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.black,
                    backgroundColor: AppColors.surfaceDark,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact List
          Expanded(
            child: Builder(builder: (context) {
                if (contactsAsync.isLoading && contactsAsync.contacts.isEmpty) {
                   return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                if (contactsAsync.contacts.isEmpty && contactsAsync.error != null) {
                   return Center(child: Text('Error: ${contactsAsync.error}', style: const TextStyle(color: Colors.redAccent)));
                }

                // If we have data (even with error), show it
                final filtered = _filterAndSortContacts(contactsAsync.contacts);
                
                if (filtered.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            const Text('No contacts found. Pull to refresh.', style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _ContactCard(
                      contact: filtered[index],
                      onDraftPressed: () => _showDraftComposer(filtered[index]),
                    );
                  },
                );
            }),
          ),
        ],
      ),
      ),
    );
  }

  List<Contact> _filterAndSortContacts(List<Contact> contacts) {
    var filtered = contacts.where((c) {
      // 1. Search Query
      final name = c.name?.toLowerCase() ?? '';
      final email = c.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      if (!name.contains(query) && !email.contains(query)) {
        return false;
      }

      // 2. Filter Logic
      switch (_selectedFilter) {
        case 'High Health':
          return c.healthScore >= 80;
        case 'Drifting':
          return c.healthScore < 50; 
        case 'New':
          // Logic: Tagged 'New' OR created in last 7 days (if createdAt exists) OR just check interaction count/tags
          // Assuming 'New' tag is populated by server or client logic.
          // Fallback: If score is 0 and no recent interactions?
          return c.tags?.contains('New') ?? false; 
        case 'All Contacts':
        default:
          return true;
      }
    }).toList();

    // 3. Sorting (Descending by Last Interaction Time)
    // User requested "assending time mails", assuming latest at top.
    filtered.sort((a, b) {
      final aTime = a.lastContacted ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastContacted ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime); // Descending
    });

    return filtered;
  }
}

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onDraftPressed;

  const _ContactCard({
    required this.contact,
    required this.onDraftPressed,
  });

  @override
  Widget build(BuildContext context) {
    final initials = contact.name?.isNotEmpty == true
        ? contact.name!.split(' ').take(2).map((e) => e[0]).join().toUpperCase()
        : contact.email[0].toUpperCase();

    final isDrifting = contact.healthScore < 50;
    final isNew = contact.tags?.contains('New') ?? false;
    final isHighHealth = contact.healthScore > 80;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18182F).withOpacity(0.6), // Glass-ish
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getAvatarColor(contact.name ?? ''),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Center(
                  child: contact.avatarUrl != null
                      ? ClipOval(child: Image.network(contact.avatarUrl!, fit: BoxFit.cover))
                      : Text(initials, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getHealthColor(contact.healthScore),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.backgroundDark, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        contact.name ?? contact.email,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _getTimeSince(contact.lastContacted),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32, 
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                        onPressed: onDraftPressed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Tags and Context
                Row(
                  children: [
                    if (isDrifting)
                       _Tag(label: 'DRIFTING', color: Colors.amber),
                    if (isNew)
                       _Tag(label: 'NEW', color: AppColors.primary),
                    if (isHighHealth)
                       // _Tag(label: 'HEALTHY', color: Colors.green),
                       const SizedBox(),
                    
                    if (isDrifting || isNew) const SizedBox(width: 8),

                    Expanded(
                      child: Row(
                        children: [
                          if (!isDrifting && !isNew) ...[
                             Icon(Icons.history, size: 14, color: Colors.white.withOpacity(0.4)),
                             const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              contact.summary ?? 'No recent context',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String seed) {
    final colors = [
      Colors.indigo.shade900,
      Colors.purple.shade900,
      Colors.teal.shade900,
      Colors.pink.shade900,
      Colors.orange.shade900,
    ];
    return colors[seed.length % colors.length].withOpacity(0.6);
  }
  
  Color _getHealthColor(double score) {
    if (score > 80) return Colors.green;
    if (score > 40) return Colors.amber;
    return Colors.red;
  }

  String _getTimeSince(DateTime? date) {
    if (date == null) return 'Never';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
