import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import '../../utils/theme.dart';
import '../../utils/extensions.dart';

class SessionCard extends StatelessWidget {
  final SessionLog session;
  final bool isTrainer;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.isTrainer = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Text(
                      isTrainer
                          ? session.guruName.initials
                          : session.trainerName.initials,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session with ${isTrainer ? session.guruName : session.trainerName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.startedAt.scheduleLabel,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCallStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.timer_outlined,
                    session.formattedDuration,
                  ),
                  const SizedBox(width: 16),
                  if (session.rating != null)
                    _buildRatingDisplay(session.rating!),
                ],
              ),
              if (session.guruNotes != null || session.trainerNotes != null) ...[
                const SizedBox(height: 12),
                if (session.guruNotes != null)
                  _buildNoteRow('Member notes', session.guruNotes!),
                if (session.trainerNotes != null) ...[
                  if (session.guruNotes != null) const SizedBox(height: 6),
                  _buildNoteRow('Trainer notes', session.trainerNotes!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallStatusBadge() {
    Color color;
    IconData icon;

    switch (session.callStatus) {
      case 'completed':
        color = AppTheme.success;
        icon = Icons.check_circle_outline;
      case 'dropped':
        color = AppTheme.warning;
        icon = Icons.warning_amber_outlined;
      case 'missed':
        color = AppTheme.error;
        icon = Icons.phone_missed_outlined;
      default:
        color = AppTheme.textTertiary;
        icon = Icons.info_outline;
    }

    return Icon(icon, color: color, size: 22);
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDisplay(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 18,
          color: i < rating ? AppTheme.warning : AppTheme.textTertiary,
        );
      }),
    );
  }

  Widget _buildNoteRow(String label, String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            note,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
