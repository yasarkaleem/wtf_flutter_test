import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

import 'chat_detail_screen.dart';

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
      appBar: AppBar(title: const Text('Schedule Session')),
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
                // Day selector
                const Text(
                  'Select Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.availableDays.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final day = state.availableDays[index];
                      final isSelected = state.selectedDay?.day == day.day &&
                          state.selectedDay?.month == day.month;

                      return GestureDetector(
                        onTap: () => context
                            .read<ScheduleBloc>()
                            .add(ScheduleSelectDay(day)),
                        child: AnimatedContainer(
                          duration: AppTheme.animFast,
                          width: 72,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day.dateLabel.split(',').first,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white70
                                      : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Time slots
                const Text(
                  'Available Slots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (state.availableSlots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: EmptyState(
                      icon: Icons.event_busy,
                      title: 'No available slots',
                      subtitle: 'Try selecting a different day',
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.availableSlots.map((slot) {
                      final isSelected =
                          state.selectedSlot == slot;

                      return ChoiceChip(
                        label: Text(slot.fullTimestamp),
                        selected: isSelected,
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        onSelected: (_) => context
                            .read<ScheduleBloc>()
                            .add(ScheduleSelectSlot(slot)),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.selectedSlot != null && !state.isLoading
                        ? () {
                            context.read<ScheduleBloc>().add(
                                  ScheduleCreate(
                                    scheduledAt: state.selectedSlot!,
                                  ),
                                );
                          }
                        : null,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Request Session'),
                  ),
                ),

                const SizedBox(height: 32),

                // Upcoming schedules
                if (state.schedules.isNotEmpty) ...[
                  const Text(
                    'Your Schedules',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.schedules.map((schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ScheduleCard(
                          schedule: schedule,
                          isTrainer: false,
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
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
