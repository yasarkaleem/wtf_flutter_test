import 'package:flutter_test/flutter_test.dart';
import 'package:guru_app/main.dart';

void main() {
  testWidgets('GuruApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const GuruApp());
    expect(find.text('Guru App'), findsOneWidget);
  });
}
