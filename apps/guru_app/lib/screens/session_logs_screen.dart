import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class SessionLogsScreen extends StatefulWidget {
  const SessionLogsScreen({super.key});

  @override
  State<SessionLogsScreen> createState() => _SessionLogsScreenState();
}

class _SessionLogsScreenState extends State<SessionLogsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionBloc>().add(SessionLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    _filterChip(context, 'All', SessionFilter.all, state),
                    const SizedBox(width: 8),
                    _filterChip(context, 'Last 7 Days', SessionFilter.last7Days, state),
                    const SizedBox(width: 8),
                    _filterChip(context, 'This Month', SessionFilter.thisMonth, state),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Session list
              Expanded(
                child: state.filteredSessions.isEmpty
                    ? const EmptyState(
                        icon: Icons.history,
                        title: 'No sessions found',
                        subtitle: 'Your completed sessions will appear here',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredSessions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final session = state.filteredSessions[index];
                          return SessionCard(
                            session: session,
                            isTrainer: false,
                            onTap: () => _showSessionDetail(context, session),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    SessionFilter filter,
    SessionState state,
  ) {
    final isSelected = state.currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (_) =>
          context.read<SessionBloc>().add(SessionFilterChanged(filter)),
    );
  }

  void _showSessionDetail(BuildContext context, SessionLog session) {
    final ratingController = TextEditingController();
    final notesController = TextEditingController(text: session.guruNotes ?? '');
    int selectedRating = session.rating ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Session with ${session.trainerName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.startedAt.scheduleLabel} | ${session.formattedDuration}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rating
                  const Text(
                    'Rate this session',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedRating = i + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            i < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: i < selectedRating
                                ? AppTheme.warning
                                : AppTheme.textTertiary,
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Notes
                  const Text(
                    'Your notes',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add notes about this session...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedRating > 0) {
                          this.context.read<SessionBloc>().add(
                                SessionAddRating(
                                  sessionId: session.id,
                                  rating: selectedRating,
                                ),
                              );
                        }
                        if (notesController.text.trim().isNotEmpty) {
                          this.context.read<SessionBloc>().add(
                                SessionAddNotes(
                                  sessionId: session.id,
                                  notes: notesController.text.trim(),
                                  isTrainer: false,
                                ),
                              );
                        }
                        Navigator.pop(context);
                        this.context.showSnackBar('Session updated!');
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    ratingController.dispose();
  }
}
