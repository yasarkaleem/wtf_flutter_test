import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/domain/entities/message.dart';
import 'package:shared/presentation/widgets/chat_bubble.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  Message createMessage({
    String content = 'Hello there!',
    String status = 'sent',
    String type = 'text',
  }) {
    return Message(
      id: 'msg-1',
      chatRoomId: 'room-1',
      senderId: 'user-1',
      senderName: 'John Doe',
      content: content,
      timestamp: DateTime(2025, 6, 15, 14, 30),
      status: status,
      type: type,
    );
  }

  group('ChatBubble', () {
    testWidgets('renders message content text', (tester) async {
      final message = createMessage(content: 'Test message content');

      await tester.pumpWidget(buildTestWidget(
        ChatBubble(message: message, isMine: true),
      ));

      expect(find.text('Test message content'), findsOneWidget);
    });

    testWidgets('shows system message with italic style for system type messages', (tester) async {
      final message = createMessage(
        content: 'User joined the chat',
        type: 'system',
      );

      await tester.pumpWidget(buildTestWidget(
        ChatBubble(message: message, isMine: false),
      ));

      expect(find.text('User joined the chat'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('User joined the chat'));
      expect(textWidget.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('shows timestamp for regular messages', (tester) async {
      final message = createMessage();

      await tester.pumpWidget(buildTestWidget(
        ChatBubble(message: message, isMine: true),
      ));

      // fullTimestamp formats as HH:mm
      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator for sending status when isMine is true', (tester) async {
      final message = createMessage(status: 'sending');

      await tester.pumpWidget(buildTestWidget(
        ChatBubble(message: message, isMine: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows single check icon for sent status when isMine is true', (tester) async {
      final message = createMessage(status: 'sent');

      await tester.pumpWidget(buildTestWidget(
        ChatBubble(message: message, isMine: true),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('aligns right for sent messages (isMine=true)', (tester) async {
      final message = createMessage();

      await tester.pumpWidget(buildTestWidget(
        ChatBubble(message: message, isMine: true),
      ));

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('aligns left for received messages (isMine=false)', (tester) async {
      final message = createMessage();

      await tester.pumpWidget(buildTestWidget(
        ChatBubble(message: message, isMine: false),
      ));

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
    });
  });
}
