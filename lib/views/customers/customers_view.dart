import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/invoice.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_package.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/models/package_manifest.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/id_generator.dart';
import 'package:galabau_app/services/invoicing/invoice_repository.dart';
import 'package:galabau_app/services/map/map_marker_builder.dart';
import 'package:galabau_app/services/storage/invoice_storage_service.dart';
import 'package:galabau_app/services/orders/order_package_repository.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/services/packages/order_import_service.dart';
import 'package:galabau_app/services/packages/package_service.dart';
import 'package:galabau_app/services/work/work_media_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:galabau_app/views/customers/client_detail_screen.dart';
import 'package:galabau_app/views/customers/client_form_dialog.dart';
import 'package:galabau_app/views/customers/order_detail_screen.dart';
import 'package:galabau_app/views/customers/order_form_dialog.dart';
import 'package:galabau_app/views/map/map_screen.dart';
import 'package:galabau_app/views/shared/empty_state.dart';
import 'package:galabau_app/views/shared/error_state.dart';
import 'package:galabau_app/views/theme/app_colors.dart';

/// Bereich „Kunden“ mit den beiden Ansichten „Kunden“ und „Aufträge“.
class CustomersView extends ConsumerWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kunden'),
          actions: <Widget>[
            Builder(
              builder: (BuildContext context) {
                final int tabIndex = DefaultTabController.of(context).index;
                if (tabIndex != 1) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.unarchive_outlined),
                  tooltip: 'Paket importieren',
                  onPressed: () => _importPackage(context, ref),
                );
              },
            ),
            Builder(
              builder: (BuildContext context) {
                final int tabIndex = DefaultTabController.of(context).index;
                return IconButton(
                  icon: const Icon(Icons.map_outlined),
                  tooltip: 'Karte',
                  onPressed: () => _openMap(context, tabIndex),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Kunden'), Tab(text: 'Aufträge')],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[_ClientList(), _OrderList()],
        ),
      ),
    );
  }

  void _openMap(BuildContext context, int tabIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MapScreen(
          initialFilter: tabIndex == 1
              ? MapFilter.offeneAuftraege
              : MapFilter.kunden,
        ),
      ),
    );
  }

  Future<void> _importPackage(BuildContext context, WidgetRef ref) async {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.any,
      allowedExtensions: const <String>['galabau', 'zip'],
    );
    if (files.isEmpty || !context.mounted) return;

    final Uint8List bytes = await files.single.readAsBytes();
    if (!context.mounted) return;

    final PackageContent? content = const PackageService().readPackage(bytes);
    if (content == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ungültiges Paket.')),
      );
      return;
    }
    if (content.manifest.type == 'rückmeldung') {
      await _importFeedback(context, ref, content);
      return;
    }
    if (content.manifest.type == 'rechnung') {
      await _importInvoice(context, ref, content);
      return;
    }
    if (content.manifest.type != 'auftrag') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unbekannter Paket-Typ.')),
      );
      return;
    }

    final String orderId = newId();
    final Order order = buildImportedOrder(
      orderId: orderId,
      manifest: content.manifest,
    );
    await ref.read(orderRepositoryProvider).insert(order);
    await ref.read(orderPackageRepositoryProvider).insert(
          buildImportedPackage(
            packageId: content.manifest.id,
            orderId: orderId,
          ),
        );
    ref.invalidate(ordersProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auftrag importiert (externe Aufträge).')),
      );
    }
  }

  Future<void> _importFeedback(
    BuildContext context,
    WidgetRef ref,
    PackageContent content,
  ) async {
    final String packageId = content.manifest.id;
    final OrderPackage? pkg = await ref
        .read(orderPackageRepositoryProvider)
        .getByPackageId(packageId);
    if (!context.mounted) return;
    if (pkg == null || pkg.orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein passender Auftrag gefunden.')),
      );
      return;
    }

    final Order? order =
        await ref.read(orderRepositoryProvider).getById(pkg.orderId!);
    if (!context.mounted) return;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auftrag nicht gefunden.')),
      );
      return;
    }

    final Directory base = await getApplicationDocumentsDirectory();
    final WorkMediaService mediaService = WorkMediaService(baseDirectory: base);

    for (final MapEntry<String, Uint8List> entry in content.files.entries) {
      final int slash = entry.key.indexOf('/');
      final String subfolder =
          slash >= 0 ? entry.key.substring(0, slash) : '';
      final String fileName =
          slash >= 0 ? entry.key.substring(slash + 1) : entry.key;
      await mediaService.saveMedia(
        orderTitle: order.title,
        subfolder: subfolder,
        fileName: fileName,
        bytes: entry.value,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rückmeldung erhalten und zugeordnet.')),
      );
    }
  }

  Future<void> _importInvoice(
    BuildContext context,
    WidgetRef ref,
    PackageContent content,
  ) async {
    final String packageId = content.manifest.id;
    final OrderPackage? pkg = await ref
        .read(orderPackageRepositoryProvider)
        .getByPackageId(packageId);
    if (!context.mounted) return;
    if (pkg == null || pkg.orderId == null || pkg.colleagueId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein passender Auftrag/Kollege gefunden.')),
      );
      return;
    }

    final Order? order =
        await ref.read(orderRepositoryProvider).getById(pkg.orderId!);
    if (!context.mounted) return;
    if (order == null || order.clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auftrag nicht gefunden.')),
      );
      return;
    }

    final PackageManifest manifest = content.manifest;
    final String number = manifest.invoiceNumber ?? manifest.title;
    final int grossCents = manifest.grossCents ?? 0;
    final int netCents = manifest.netCents ?? 0;
    final Invoice invoice = Invoice(
      id: newId(),
      number: number,
      type: 'invoice',
      clientId: order.clientId!,
      orderId: order.id,
      colleagueId: pkg.colleagueId,
      status: 'issued',
      issuedDate: manifest.issuedDate ?? DateTime.now(),
      netCents: netCents,
      vatRateBp: 1900,
      vatCents: grossCents - netCents,
      grossCents: grossCents,
      createdAt: DateTime.now(),
    );
    await ref.read(invoiceRepositoryProvider).insert(invoice);

    final Uint8List? pdfBytes = content.files['rechnung.pdf'];
    if (pdfBytes != null) {
      final Directory base = await getApplicationDocumentsDirectory();
      final InvoiceStorageService storage =
          InvoiceStorageService(baseDirectory: base);
      await storage.saveInvoicePdf(
        orderTitle: order.title,
        fileName: '$number.pdf',
        pdfBytes: pdfBytes,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rechnung empfangen und zugeordnet.')),
      );
    }
  }
}

/// Filter für die Auftragsliste (laut Vision 4.3: Offen, Erledigt,
/// wiederkehrend).
enum _OrderFilter { offen, erledigt, wiederkehrend }

/// Herkunft eines Auftrags (Filter: eigene vs. externe Aufträge).
enum _OrderOriginFilter { meine, externe }

class _ClientList extends ConsumerStatefulWidget {
  const _ClientList();

  @override
  ConsumerState<_ClientList> createState() => _ClientListState();
}

class _ClientListState extends ConsumerState<_ClientList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Client>> clients = ref.watch(clientsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addClient(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Kunde'),
      ),
      body: clients.when(
        data: (List<Client> all) {
          final List<Client> filtered = _query.isEmpty
              ? all
              : all
                  .where((Client c) =>
                      c.name.toLowerCase().contains(_query.toLowerCase()))
                  .toList();
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (String value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Suchen …',
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'Noch keine Kunden',
                        message: 'Fügen Sie über „Kunde“ Ihren ersten Kunden hinzu.',
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Client client = filtered[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(client.name),
                              subtitle: Text(
                                  '${client.zip} ${client.city}'.trim()),
                              onTap: () => _showClient(context, client),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(onRetry: () => ref.invalidate(clientsProvider)),
      ),
    );
  }

  Future<void> _addClient(BuildContext context) async {
    final bool? created = await showDialog<bool>(
      context: context,
      builder: (_) => const ClientFormDialog(),
    );
    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunde angelegt')),
      );
    }
  }

  void _showClient(BuildContext context, Client client) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientDetailScreen(client: client),
      ),
    );
  }
}

class _OrderList extends ConsumerStatefulWidget {
  const _OrderList();

  @override
  ConsumerState<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<_OrderList> {
  final Set<_OrderFilter> _filters = <_OrderFilter>{_OrderFilter.offen};
  final Set<_OrderOriginFilter> _origins = <_OrderOriginFilter>{
    _OrderOriginFilter.meine,
  };

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Order>> orders = ref.watch(ordersProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrder(context),
        icon: const Icon(Icons.add),
        label: const Text('Auftrag'),
      ),
      body: orders.when(
        data: (List<Order> all) {
          final List<Order> filtered = all.where(_matches).toList();
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      children: <Widget>[
                        for (final _OrderOriginFilter o
                            in _OrderOriginFilter.values)
                          FilterChip(
                            label: Text(_originLabel(o)),
                            selected: _origins.contains(o),
                            onSelected: (bool selected) => setState(() {
                              selected ? _origins.add(o) : _origins.remove(o);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: <Widget>[
                        for (final _OrderFilter f in _OrderFilter.values)
                          FilterChip(
                            label: Text(_filterLabel(f)),
                            selected: _filters.contains(f),
                            onSelected: (bool selected) => setState(() {
                              selected ? _filters.add(f) : _filters.remove(f);
                            }),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Noch keine Aufträge',
                        message: 'Legen Sie über „Auftrag“ Ihren ersten Auftrag an.',
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Order order = filtered[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statusColor(order),
                                child: Icon(
                                  order.status == OrderStatus.erledigt
                                      ? Icons.check
                                      : Icons.event,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(order.title),
                              subtitle: Text(_statusText(order)),
                              onTap: () => _openOrder(context, order),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(onRetry: () => ref.invalidate(ordersProvider)),
      ),
    );
  }

  bool _matches(Order order) {
    final bool originMatch = switch (order.origin) {
      'eigen' => _origins.contains(_OrderOriginFilter.meine),
      'erhalten' => _origins.contains(_OrderOriginFilter.externe),
      _ => false,
    };
    final bool statusMatch =
        (order.status == OrderStatus.offen &&
            _filters.contains(_OrderFilter.offen)) ||
            (order.status == OrderStatus.erledigt &&
                _filters.contains(_OrderFilter.erledigt)) ||
            (order.recurring && _filters.contains(_OrderFilter.wiederkehrend));
    return originMatch && statusMatch;
  }

  String _filterLabel(_OrderFilter filter) {
    return switch (filter) {
      _OrderFilter.offen => 'Offen',
      _OrderFilter.erledigt => 'Erledigt',
      _OrderFilter.wiederkehrend => 'Wiederkehrend',
    };
  }

  String _originLabel(_OrderOriginFilter origin) {
    return switch (origin) {
      _OrderOriginFilter.meine => 'Meine Aufträge',
      _OrderOriginFilter.externe => 'Externe Aufträge',
    };
  }

  Color _statusColor(Order order) {
    if (order.recurring) return AppColors.statusRecurring;
    return order.status == OrderStatus.erledigt
        ? AppColors.statusDone
        : AppColors.statusOpen;
  }

  String _statusText(Order order) {
    final String status = order.status == OrderStatus.erledigt ? 'Erledigt' : 'Offen';
    return order.recurring ? '$status · wiederkehrend' : status;
  }

  void _openOrder(BuildContext context, Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrderDetailScreen(order: order)),
    );
  }

  Future<void> _addOrder(BuildContext context) async {
    final Order? order = await showDialog<Order>(
      context: context,
      builder: (_) => const OrderFormDialog(),
    );
    if (order != null && context.mounted) {
      ref.invalidate(ordersProvider);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailScreen(order: order),
        ),
      );
    }
  }
}
