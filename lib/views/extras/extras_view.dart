import 'package:flutter/material.dart';

import 'invoice_management_view.dart';
import 'settings_screen.dart';

/// Menüpunkt „Extras“: Rechnungsverwaltung sowie Stammdaten & Design.
class ExtrasView extends StatelessWidget {
  const ExtrasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extras')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _ExtrasEntry(
            icon: Icons.receipt_long_outlined,
            title: 'Rechnungsverwaltung',
            subtitle: 'Einnahmen und Ausgaben (Material- und Personalkosten)',
            onTap: () => _openInvoices(context),
          ),
          const SizedBox(height: 12),
          _ExtrasEntry(
            icon: Icons.palette_outlined,
            title: 'Rechnungsdesign',
            subtitle: 'Stammdaten & Layout (Logo, Akzentfarbe, Blöcke)',
            onTap: () => _openSettings(context),
          ),
          const SizedBox(height: 12),
          _ExtrasEntry(
            icon: Icons.request_quote_outlined,
            title: 'Angebotsdesign',
            subtitle: 'Dieselbe Engine, eigene Nummern (AN-)',
            onTap: () => _openSettings(context),
          ),
        ],
      ),
    );
  }

  void _openInvoices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const InvoiceManagementView()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }
}

class _ExtrasEntry extends StatelessWidget {
  const _ExtrasEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

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
        enabled: onTap != null,
        onTap: onTap,
      ),
    );
  }
}