import 'package:flutter/material.dart';
import '../utils/extensions.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final bool showOnlineIndicator;
  final bool isOnline;

  const AvatarWidget({
    super.key,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final textColor = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          child: Text(
            name.initials,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: radius * 0.7,
            ),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
