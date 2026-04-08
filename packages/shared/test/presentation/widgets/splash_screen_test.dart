import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/presentation/widgets/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    Widget buildSplash({VoidCallback? onComplete}) {
      return MaterialApp(
        home: SplashScreen(
          primaryColor: Colors.blue,
          icon: Icons.fitness_center,
          appName: 'WTF Fitness',
          onComplete: onComplete ?? () {},
        ),
      );
    }

    testWidgets('renders app name text', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump();
      expect(find.text('WTF Fitness'), findsOneWidget);
      // Drain the pending timer so the test doesn't fail
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump();
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets('calls onComplete after delay', (tester) async {
      bool completed = false;

      await tester.pumpWidget(buildSplash(
        onComplete: () => completed = true,
      ));

      expect(completed, isFalse);
      await tester.pump(const Duration(milliseconds: 1800));
      expect(completed, isTrue);
    });
  });
}
