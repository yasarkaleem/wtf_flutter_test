import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/presentation/widgets/empty_state.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('EmptyState', () {
    testWidgets('renders title and subtitle text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'No Messages',
          subtitle: 'Start a conversation',
        ),
      ));

      expect(find.text('No Messages'), findsOneWidget);
      expect(find.text('Start a conversation'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'No Messages',
        ),
      ));

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('shows action widget when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState(
          icon: Icons.inbox,
          title: 'No Messages',
          action: ElevatedButton(
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ),
      ));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('hides subtitle when null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'No Messages',
          subtitle: null,
        ),
      ));

      expect(find.text('No Messages'), findsOneWidget);
      // Only one Text widget should exist (the title), not a subtitle
      final textWidgets = find.byType(Text);
      // The title Text widget exists
      expect(find.text('No Messages'), findsOneWidget);
      // There should be no subtitle text widget beyond the title
      // We verify by counting Text widgets in the Column
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);
      final column = tester.widget<Column>(columnFinder);
      // When subtitle is null, the column should not contain a subtitle Text
      // We just verify there's only one Text widget descendant (the title)
      final allText = find.descendant(
        of: columnFinder,
        matching: find.byType(Text),
      );
      expect(allText, findsOneWidget);
    });
  });
}
