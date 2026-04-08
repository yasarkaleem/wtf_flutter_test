import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/schedule/schedule_bloc.dart';
import '../../utils/theme.dart';

/// Camera icon with a green badge dot when an imminent call exists.
class CallBadgeIcon extends StatelessWidget {
  final VoidCallback onTap;

  const CallBadgeIcon({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      buildWhen: (prev, curr) =>
          (prev.imminentCall != null) != (curr.imminentCall != null),
      builder: (context, state) {
        final hasImminent = state.imminentCall != null;

        return IconButton(
          onPressed: onTap,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.videocam_outlined),
              if (hasImminent)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
