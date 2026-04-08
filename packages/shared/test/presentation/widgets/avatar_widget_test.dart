import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/presentation/widgets/avatar_widget.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('AvatarWidget', () {
    testWidgets('shows initials for two-word name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AvatarWidget(name: 'David Kim'),
      ));

      // The initials extension takes first letter of each word => "DK"
      expect(find.text('DK'), findsOneWidget);
    });

    testWidgets('shows initials for single-word name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AvatarWidget(name: 'Alice'),
      ));

      // Single word: takes first 2 chars => "AL"
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('shows online indicator when showOnlineIndicator is true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AvatarWidget(
          name: 'David Kim',
          showOnlineIndicator: true,
          isOnline: true,
        ),
      ));

      // The Stack should contain the CircleAvatar and the positioned indicator container
      // When showOnlineIndicator is true, we expect a Positioned widget in the Stack
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('hides online indicator when showOnlineIndicator is false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AvatarWidget(
          name: 'David Kim',
          showOnlineIndicator: false,
        ),
      ));

      // When showOnlineIndicator is false, no Positioned widget should appear
      expect(find.byType(Positioned), findsNothing);
    });
  });
}
