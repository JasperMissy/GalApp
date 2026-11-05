import 'package:flutter/material.dart';
import 'package:galabau_app/views/shared/empty_state.dart';

/// Einfache Kalenderfunktion.
///
/// Gerüst: Die Terminansicht folgt mit der Auftragsverwaltung.
class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender')),
      body: const EmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'Noch keine Termine',
        message:
            'Ausführungstermine offener Aufträge erscheinen hier im Kalender.',
      ),
    );
  }
}
