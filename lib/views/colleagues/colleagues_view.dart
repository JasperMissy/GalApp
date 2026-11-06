import 'package:flutter/material.dart';
import 'package:galabau_app/services/map/map_marker_builder.dart';
import 'package:galabau_app/views/map/map_screen.dart';
import 'package:galabau_app/views/shared/empty_state.dart';

/// Kollegen-Datenbank: alphabetische Kontaktliste mit Qualifikationen.
///
/// Gerüst: Liste und Details folgen mit der Fachlogik.
class ColleaguesView extends StatelessWidget {
  const ColleaguesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kollegen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Karte',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MapScreen(initialFilter: MapFilter.kollegen),
              ),
            ),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.groups_outlined,
        title: 'Noch keine Kollegen',
        message:
            'Hier erscheint die alphabetische Kontaktliste mit Qualifikationen wie SKT-A, SKT-B oder Hängerführerschein.',
      ),
    );
  }
}
