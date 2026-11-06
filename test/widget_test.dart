import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/main.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/services/colleagues/colleague_repository.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/orders/order_repository.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    List<Client> clients = const <Client>[],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientsProvider.overrideWith((ref) => Future.value(clients)),
          ordersProvider.overrideWith((ref) => Future.value(const [])),
          colleaguesProvider.overrideWith((ref) => Future.value(const [])),
        ],
        child: const GalabauApp(),
      ),
    );
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

  testWidgets('Kundenliste zeigt vorhandene Kunden',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      clients: <Client>[
        Client(
          id: 'k-1',
          name: 'Max Mustermann',
          street: 'Beispielweg 1',
          zip: '34123',
          city: 'Kassel',
          phone: '',
          email: '',
          createdAt: DateTime(2026),
        ),
      ],
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Kunden'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Max Mustermann'), findsOneWidget);
  });
}