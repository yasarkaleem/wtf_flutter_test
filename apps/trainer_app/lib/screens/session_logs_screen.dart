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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    _filterChip(context, 'All', SessionFilter.all, state),
                    const SizedBox(width: 8),
                    _filterChip(
                        context, 'Last 7 Days', SessionFilter.last7Days, state),
                    const SizedBox(width: 8),
                    _filterChip(
                        context, 'This Month', SessionFilter.thisMonth, state),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: state.filteredSessions.isEmpty
                    ? const EmptyState(
                        icon: Icons.history,
                        title: 'No sessions found',
                        subtitle: 'Completed sessions with members appear here',
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
                            isTrainer: true,
                            onTap: () =>
                                _showSessionDetail(context, session),
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
    final notesController =
        TextEditingController(text: session.trainerNotes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                'Session with ${session.guruName}',
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
              const SizedBox(height: 16),

              // Member rating (read-only for trainer)
              if (session.rating != null) ...[
                const Text(
                  'Member Rating',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < session.rating!
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < session.rating!
                          ? AppTheme.warning
                          : AppTheme.textTertiary,
                      size: 28,
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],

              // Member notes (read-only)
              if (session.guruNotes != null) ...[
                const Text(
                  'Member Notes',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    session.guruNotes!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Trainer notes
              const Text(
                'Your Notes',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add your notes about this session...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (notesController.text.trim().isNotEmpty) {
                      this.context.read<SessionBloc>().add(
                            SessionAddNotes(
                              sessionId: session.id,
                              notes: notesController.text.trim(),
                              isTrainer: true,
                            ),
                          );
                    }
                    Navigator.pop(context);
                    this.context.showSnackBar('Notes saved!');
                  },
                  child: const Text('Save Notes'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
