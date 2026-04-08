import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'call_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(ScheduleLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Requests')),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state.error != null) {
            context.showSnackBar(state.error!, isError: true);
          }
          if (state.successMessage != null) {
            context.showSnackBar(state.successMessage!);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending requests
                if (state.pendingSchedules.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'Pending Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${state.pendingSchedules.length}',
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...state.pendingSchedules.map((schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ScheduleCard(
                          schedule: schedule,
                          isTrainer: true,
                          onApprove: () => context
                              .read<ScheduleBloc>()
                              .add(ScheduleApprove(schedule.id)),
                          onDecline: () => context
                              .read<ScheduleBloc>()
                              .add(ScheduleDecline(schedule.id)),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                // Upcoming approved
                if (state.upcomingApproved.isNotEmpty) ...[
                  const Text(
                    'Upcoming Sessions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.upcomingApproved.map((schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ScheduleCard(
                          schedule: schedule,
                          isTrainer: true,
                          onCancel: () => context
                              .read<ScheduleBloc>()
                              .add(ScheduleCancel(schedule.id)),
                          onJoinCall: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PreJoinScreen(),
                              ),
                            );
                          },
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                // All schedules
                const Text(
                  'All Schedules',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (state.schedules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: EmptyState(
                      icon: Icons.calendar_today_outlined,
                      title: 'No schedule requests',
                      subtitle: 'Members will send you session requests',
                    ),
                  )
                else
                  ...state.schedules
                      .where((s) =>
                          s.status != 'pending' ||
                          !state.pendingSchedules.contains(s))
                      .map((schedule) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ScheduleCard(
                              schedule: schedule,
                              isTrainer: true,
                            ),
                          )),
              ],
            ),
          );
        },
      ),
    );
  }
}

