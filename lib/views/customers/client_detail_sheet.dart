import 'package:flutter/material.dart';
import 'package:galabau_app/models/client.dart';
import 'package:url_launcher/url_launcher.dart';

import 'client_invoices_screen.dart';

/// Kundendetails mit Schnellaktionen (Anrufen, Navigation, E-Mail) laut
/// Vision, Abschnitt 3.2.
class ClientDetailSheet extends StatelessWidget {
  const ClientDetailSheet({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            client.name,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${client.street}\n${client.zip} ${client.city}'.trim(),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionTile(
                  icon: Icons.call,
                  label: 'Anrufen',
                  onTap: () => _launch('tel:${client.phone}'),
                ),
              ),
              Expanded(
                child: _ActionTile(
                  icon: Icons.navigation_outlined,
                  label: 'Navi',
                  onTap: () => _launch(
                    'geo:0,0?q=${Uri.encodeComponent('${client.street} ${client.zip} ${client.city}')}',
                  ),
                ),
              ),
              Expanded(
                child: _ActionTile(
                  icon: Icons.mail_outline,
                  label: 'Mail',
                  onTap: () => _launch('mailto:${client.email}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.folder_outlined,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Rechnungsordner',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Alle Rechnungen dieses Kunden'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openInvoices(context),
          ),
        ],
      ),
    );
  }

  void _openInvoices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientInvoicesScreen(clientId: client.id),
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final Uri parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed);
    }
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}