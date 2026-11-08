import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pockiva/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Pockiva app launches', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Save40App(initialDarkMode: true),
    );

    expect(find.byType(Save40App), findsOneWidget);

    // Advance past the 1.3-second splash timer.
    await tester.pump(const Duration(seconds: 2));

    // Render the next frame without waiting for endless animations.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Save40App), findsOneWidget);
  });
}