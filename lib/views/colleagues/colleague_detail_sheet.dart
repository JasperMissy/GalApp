import 'package:flutter/material.dart';
import 'package:galabau_app/models/colleague.dart';
import 'package:url_launcher/url_launcher.dart';

/// Kollegendetails mit Qualifikationen und Schnellaktionen (Anrufen,
/// Navigation, E-Mail) sowie einem Platzhalter für den Rechnungsordner.
class ColleagueDetailSheet extends StatelessWidget {
  const ColleagueDetailSheet({super.key, required this.colleague});

  final Colleague colleague;

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
            colleague.name,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${colleague.street}\n${colleague.zip} ${colleague.city}'.trim(),
            style: textTheme.bodyMedium,
          ),
          if (colleague.qualifications.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String q in colleague.qualifications)
                  Chip(label: Text(q)),
              ],
            ),
          ],
          if (colleague.notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(colleague.notes, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionTile(
                  icon: Icons.call,
                  label: 'Anrufen',
                  onTap: () => _launch('tel:${colleague.phone}'),
                ),
              ),
              Expanded(
                child: _ActionTile(
                  icon: Icons.navigation_outlined,
                  label: 'Navi',
                  onTap: () => _launch(
                    'geo:0,0?q=${Uri.encodeComponent('${colleague.street} ${colleague.zip} ${colleague.city}')}',
                  ),
                ),
              ),
              Expanded(
                child: _ActionTile(
                  icon: Icons.mail_outline,
                  label: 'Mail',
                  onTap: () => _launch('mailto:${colleague.email}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.folder_outlined,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Rechnungen',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Rechnungen dieser Person'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showInvoicesPlaceholder(context),
          ),
        ],
      ),
    );
  }

  void _showInvoicesPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rechnungsimport folgt mit dem Subunternehmer-Workflow.'),
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
