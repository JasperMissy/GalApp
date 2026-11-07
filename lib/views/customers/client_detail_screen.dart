import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/views/customers/client_invoices_screen.dart';
import 'package:galabau_app/views/customers/order_detail_screen.dart';
import 'package:galabau_app/views/customers/order_form_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Kundendetail als eigene Seite mit Rechnungsordner und Auftragsliste.
class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<Order>> orders =
        ref.watch(ordersByClientProvider(client.id));

    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrder(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Auftrag hinzufügen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ClientInvoicesScreen(clientId: client.id),
              ),
            ),
          ),
          const Divider(height: 32),
          Text('Aufträge',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          orders.when(
            data: (List<Order> all) => all.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Noch keine Aufträge für diesen Kunden.'),
                  )
                : Column(
                    children: <Widget>[
                      for (final Order order in all)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.assignment_outlined),
                            title: Text(order.title),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => OrderDetailScreen(order: order),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const Text('Aufträge konnten nicht geladen werden.'),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final Uri parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed);
    }
  }

  Future<void> _addOrder(BuildContext context, WidgetRef ref) async {
    final Order? order = await showDialog<Order>(
      context: context,
      builder: (_) => OrderFormDialog(clientId: client.id),
    );
    if (order != null && context.mounted) {
      ref.invalidate(ordersByClientProvider(client.id));
      ref.invalidate(ordersProvider);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailScreen(order: order),
        ),
      );
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
