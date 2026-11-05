import 'package:flutter/material.dart';

/// Menüpunkt „Extras“: Rechnungsverwaltung sowie Rechnungs- und
/// Angebotsvorlage.
///
/// Gerüst: Die Unterseiten folgen mit den jeweiligen Meilensteinen.
class ExtrasView extends StatelessWidget {
  const ExtrasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extras')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _ExtrasEntry(
            icon: Icons.receipt_long_outlined,
            title: 'Rechnungsverwaltung',
            subtitle: 'Einnahmen und Ausgaben (Material- und Personalkosten)',
          ),
          SizedBox(height: 12),
          _ExtrasEntry(
            icon: Icons.description_outlined,
            title: 'Rechnungsvorlage',
            subtitle: 'Eigene .docx-Vorlage hochladen und Platzhalter festlegen',
          ),
          SizedBox(height: 12),
          _ExtrasEntry(
            icon: Icons.request_quote_outlined,
            title: 'Angebotsvorlage',
            subtitle: 'Eigene .docx-Vorlage hochladen und Platzhalter festlegen',
          ),
        ],
      ),
    );
  }
}

class _ExtrasEntry extends StatelessWidget {
  const _ExtrasEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        enabled: false,
      ),
    );
  }
}
