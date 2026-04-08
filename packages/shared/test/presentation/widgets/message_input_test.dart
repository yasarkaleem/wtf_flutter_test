import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/presentation/widgets/message_input.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  Finder findSendButton() {
    return find.ancestor(
      of: find.byIcon(Icons.send_rounded),
      matching: find.byType(InkWell),
    );
  }

  group('MessageInput', () {
    testWidgets('renders text field with hint text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        MessageInput(onSend: (_) {}),
      ));

      expect(find.text('Type a message...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('send button is disabled when text is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        MessageInput(onSend: (_) {}),
      ));

      // The send button is an InkWell; when _isComposing is false, onTap is null
      final inkWell = tester.widget<InkWell>(findSendButton());
      expect(inkWell.onTap, isNull);
    });

    testWidgets('send button is enabled when text is entered', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        MessageInput(onSend: (_) {}),
      ));

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // After entering text, _isComposing becomes true and onTap is set
      final inkWell = tester.widget<InkWell>(findSendButton());
      expect(inkWell.onTap, isNotNull);
    });

    testWidgets('calls onSend callback when send button tapped', (tester) async {
      String? sentMessage;

      await tester.pumpWidget(buildTestWidget(
        MessageInput(onSend: (text) => sentMessage = text),
      ));

      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.pump();

      // Tap the send button (InkWell wrapping the send icon)
      await tester.tap(findSendButton());
      await tester.pump();

      expect(sentMessage, 'Hello World');
    });

    testWidgets('clears text field after sending', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        MessageInput(onSend: (_) {}),
      ));

      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.pump();

      await tester.tap(findSendButton());
      await tester.pump();

      // The TextField should now be empty
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('shows quick reply chips when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        MessageInput(
          onSend: (_) {},
          quickReplies: const ['Yes', 'No', 'Maybe'],
        ),
      ));

      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(3));
    });
  });
}
