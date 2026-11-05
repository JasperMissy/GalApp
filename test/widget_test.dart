import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GalabauApp()));
  }

  testWidgets('Navigationsleiste zeigt die fünf Ziele laut Skizze',
      (WidgetTester tester) async {
    await pumpApp(tester);

    final Finder bar = find.byType(NavigationBar);
    expect(bar, findsOneWidget);
    for (final String label in <String>[
      'Kunden',
      'Kalender',
      'Home',
      'Kollegen',
      'Extras',
    ]) {
      expect(
        find.descendant(of: bar, matching: find.text(label)),
        findsOneWidget,
        reason: 'Ziel "$label" fehlt in der Navigationsleiste',
      );
    }
    expect(
      find.descendant(of: bar, matching: find.text('Aufträge')),
      findsNothing,
      reason: '"Aufträge" ist kein eigener Menüpunkt',
    );
  });

  testWidgets('Die App startet auf Home', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Hallo!'), findsOneWidget);
  });

  testWidgets('Wechsel zu Kunden zeigt die Bereiche Kunden und Aufträge',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Kunden'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Aufträge'),
      ),
      findsOneWidget,
    );
    expect(find.text('Noch keine Kunden'), findsOneWidget);
  });
}
