import 'package:flutter/material.dart';
import 'package:galabau_app/views/shared/empty_state.dart';

/// Kollegen-Datenbank: alphabetische Kontaktliste mit Qualifikationen.
///
/// Gerüst: Liste und Details folgen mit der Fachlogik.
class ColleaguesView extends StatelessWidget {
  const ColleaguesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kollegen')),
      body: const EmptyState(
        icon: Icons.groups_outlined,
        title: 'Noch keine Kollegen',
        message:
            'Hier erscheint die alphabetische Kontaktliste mit Qualifikationen wie SKT-A, SKT-B oder Hängerführerschein.',
      ),
    );
  }
}
