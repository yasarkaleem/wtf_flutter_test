import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/main.dart';

void main() {
  testWidgets('TrainerApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const TrainerApp());
    expect(find.text('Trainer App'), findsOneWidget);
  });
}
