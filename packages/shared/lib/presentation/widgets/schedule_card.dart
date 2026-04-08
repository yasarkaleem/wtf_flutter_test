import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import '../../utils/theme.dart';
import '../../utils/extensions.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool isTrainer;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final VoidCallback? onJoinCall;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.isTrainer = false,
    this.onApprove,
    this.onDecline,
    this.onCancel,
    this.onJoinCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusBadge(),
                const Spacer(),
                Text(
                  schedule.scheduledAt.scheduleLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                        ? schedule.guruName.initials
                        : schedule.trainerName.initials,
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
                        'Session with ${isTrainer ? schedule.guruName : schedule.trainerName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${schedule.durationMinutes} min session',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note_outlined,
                        size: 16, color: AppTheme.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.notes!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    switch (schedule.scheduleStatus) {
      case ScheduleStatus.pending:
        color = AppTheme.warning;
        label = 'Pending';
      case ScheduleStatus.approved:
        color = AppTheme.success;
        label = 'Approved';
      case ScheduleStatus.declined:
        color = AppTheme.error;
        label = 'Declined';
      case ScheduleStatus.cancelled:
        color = AppTheme.textTertiary;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (schedule.scheduleStatus == ScheduleStatus.pending && isTrainer) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDecline,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Decline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
            ),
          ),
        ],
      );
    }

    if (schedule.scheduleStatus == ScheduleStatus.approved &&
        !schedule.isPast) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ),
          if (schedule.isJoinable) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onJoinCall,
                icon: const Icon(Icons.videocam, size: 18),
                label: const Text('Join Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
