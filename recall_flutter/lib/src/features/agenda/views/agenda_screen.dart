import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/main.dart'; // For client
import 'package:recall_flutter/src/core/app_colors.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<AgendaItem>> _agendaFuture;

  @override
  void initState() {
    super.initState();
    _loadAgenda();
  }

  void _loadAgenda() {
    // Start of day
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).toUtc();
    // End of day
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    setState(() {
      _agendaFuture = client.dashboard.getAgendaItems(start, end);
    });
  }

  void _changeDate(int offset) {
    setState(() {
      _selectedDate = DateTime.now().add(Duration(days: offset));
    });
    _loadAgenda();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final isYesterday = DateUtils.isSameDay(_selectedDate, DateTime.now().subtract(const Duration(days: 1)));
    final isTomorrow = DateUtils.isSameDay(_selectedDate, DateTime.now().add(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _BackButton(),
                      const SizedBox(width: 16),
                      const Text(
                        'Agenda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  _SettingsButton(),
                ],
              ),
            ),

            // Date Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _DateChip(
                    label: 'Yesterday',
                    isSelected: isYesterday,
                    onTap: () => _changeDate(-1),
                  ),
                  const SizedBox(width: 12),
                  _DateChip(
                    label: 'Today',
                    isSelected: isToday,
                    onTap: () => _changeDate(0),
                  ),
                  const SizedBox(width: 12),
                  _DateChip(
                    label: 'Tomorrow',
                    isSelected: isTomorrow,
                    onTap: () => _changeDate(1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: FutureBuilder<List<AgendaItem>>(
                future: _agendaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return _EmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _TimelineItem(
                        item: items[index],
                        isFirst: index == 0,
                        isLast: index == items.length - 1,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add manually
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Icon(Icons.settings, color: AppColors.primary, size: 20),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final AgendaItem item;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final timeStr = timeFormat.format(item.startTime.toLocal());
    final isHighPriority = item.priority == 'high';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          SizedBox(
            width: 60,
            child: Stack(
              children: [
                // Vertical Line
                if (!isLast)
                  Positioned(
                    top: 24,
                    left: 28, // Center of width 60 is 30. Dot is ~12-16px.
                    bottom: -24, // Connect to next
                    child: Container(
                      width: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 242, 250, 0.5), 
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                // Time
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    timeStr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: AppColors.primary, blurRadius: 10)],
                    ),
                  ),
                ),
                // Dot
                Positioned(
                  top: 24,
                  left: 21,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 32),
              child: _EventCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final AgendaItem item;

  const _EventCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final contact = item.contact;
    final hasRecall = item.description != null && item.description!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Glow Effect
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 40)],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Title + Avatars)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Optional Subtitle/Context (could come from description or snippet)
                          if (contact != null)
                             Text(
                               'with ${contact.name ?? contact.email}',
                               style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                             ),
                        ],
                      ),
                    ),
                    if (contact != null)
                      _AvatarGroup(contact: contact),
                  ],
                ),

                const SizedBox(height: 16),

                // Recall Summary Box
                if (hasRecall)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border(left: BorderSide(color: AppColors.primary, width: 2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.psychology, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RECALL SUMMARY',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description!,
                                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Reschedule Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_calendar, size: 18, color: AppColors.textSecondary),
                    label: const Text('Reschedule', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      elevation: 0,
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
}

class _AvatarGroup extends StatelessWidget {
  final Contact contact;
  const _AvatarGroup({required this.contact});

  @override
  Widget build(BuildContext context) {
    // Show single avatar for now, can support group logic if multiple participants
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceDark, width: 2),
      ),
      child: ClipOval(
        child: contact.avatarUrl != null
            ? Image.network(contact.avatarUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primary,
                child: Center(
                  child: Text(
                    contact.name?[0] ?? '?',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'No agenda items found',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
