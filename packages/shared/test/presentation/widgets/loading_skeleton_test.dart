import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/presentation/widgets/loading_skeleton.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('LoadingSkeleton', () {
    testWidgets('renders with given width and height', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Center(
          child: LoadingSkeleton(width: 200, height: 50),
        ),
      ));

      expect(find.byType(LoadingSkeleton), findsOneWidget);

      // The LoadingSkeleton renders a Shimmer wrapping a Container.
      // Verify it appears in the widget tree and has the right render size.
      final skeletonElement = tester.element(find.byType(LoadingSkeleton));
      final renderBox = skeletonElement.renderObject as RenderBox;
      expect(renderBox.size.width, 200.0);
      expect(renderBox.size.height, 50.0);
    });
  });

  group('ChatListSkeleton', () {
    testWidgets('renders the specified number of items', (tester) async {
      const itemCount = 3;

      await tester.pumpWidget(buildTestWidget(
        const ChatListSkeleton(itemCount: itemCount),
      ));

      expect(find.byType(ChatListSkeleton), findsOneWidget);

      // Each item in the ChatListSkeleton contains a Row with LoadingSkeleton children.
      // Each item has 3 LoadingSkeleton widgets (avatar, name, last-msg width, time)
      // Actually: each item row has: 1 avatar skeleton + 2 in column + 1 time = 4 per item
      // Total LoadingSkeleton widgets = itemCount * 4
      expect(
        find.byType(LoadingSkeleton),
        findsNWidgets(itemCount * 4),
      );
    });

    testWidgets('uses default itemCount of 5', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ChatListSkeleton(),
      ));

      // Default is 5 items, each with 4 LoadingSkeleton widgets
      expect(
        find.byType(LoadingSkeleton),
        findsNWidgets(5 * 4),
      );
    });
  });
}
