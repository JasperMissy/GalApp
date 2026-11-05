import 'package:flutter/material.dart';
import 'package:galabau_app/views/shared/empty_state.dart';

/// Startseite (Home): Begrüßung, Wetter und Tagesaufgaben.
///
/// Gerüst: Die Inhalte (Benutzername, Wetter, Aufgaben) folgen mit der
/// jeweiligen Fachlogik.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Hallo!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.wb_sunny_outlined),
              title: Text('Wetter'),
              subtitle: Text('Standort und Temperatur folgen'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tasks Today',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: SizedBox(
              height: 220,
              child: EmptyState(
                icon: Icons.task_alt_outlined,
                title: 'Keine Aufgaben für heute',
                message:
                    'Offene Aufträge und Termine aus dem Kalender erscheinen hier.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
