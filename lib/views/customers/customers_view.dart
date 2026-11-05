import 'package:flutter/material.dart';
import 'package:galabau_app/views/shared/empty_state.dart';

/// Bereich „Kunden“ mit den beiden Ansichten „Kunden“ und „Aufträge“.
///
/// „Aufträge“ ist laut Skizze ein Bereich innerhalb von „Kunden“ und kein
/// eigener Menüpunkt.
///
/// Gerüst: Kundenliste, Karte, Auftragsliste und Filter folgen mit dem
/// Referenz-Screen.
class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kunden'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Kunden'),
              Tab(text: 'Aufträge'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            EmptyState(
              icon: Icons.people_outline,
              title: 'Noch keine Kunden',
              message:
                  'Hier erscheint die alphabetische Kundenliste mit Suche und Karte.',
            ),
            EmptyState(
              icon: Icons.assignment_outlined,
              title: 'Noch keine Aufträge',
              message:
                  'Hier erscheint die Auftragsliste mit dem Filter Offen, Erledigt und wiederkehrend.',
            ),
          ],
        ),
      ),
    );
  }
}
