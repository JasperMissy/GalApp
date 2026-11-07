import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/services/work/work_media_service.dart';
import 'package:path_provider/path_provider.dart';

/// Übersichtsseite des Auftragsordners (scrollbar): Meta-Zeile,
/// Auftragsdetails mit Foto-Vorschau und Ausführungsdatum.
class OrderOverviewTab extends ConsumerStatefulWidget {
  const OrderOverviewTab({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<OrderOverviewTab> createState() => _OrderOverviewTabState();
}

class _OrderOverviewTabState extends ConsumerState<OrderOverviewTab> {
  List<Uint8List> _photos = <Uint8List>[];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final Directory base = await getApplicationDocumentsDirectory();
    final WorkMediaService service = WorkMediaService(baseDirectory: base);
    final Map<String, Uint8List> media =
        await service.loadMedia(widget.order.title);
    final List<Uint8List> photos = <Uint8List>[];
    for (final MapEntry<String, Uint8List> entry in media.entries) {
      if (entry.key.contains('fotos/')) photos.add(entry.value);
    }
    if (mounted) setState(() => _photos = photos);
  }

  @override
  Widget build(BuildContext context) {
    final Order order = widget.order;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _metaLine(context, order),
        const SizedBox(height: 8),
        _dueDateTile(context, order),
        if (order.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text('Beschreibung',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(order.description),
        ],
        if (order.notes.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text('Notizen',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(order.notes),
        ],
        if (_photos.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text('Bilder',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final Uint8List photo in _photos)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(photo,
                      width: 96, height: 96, fit: BoxFit.cover),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _metaLine(BuildContext context, Order order) {
    final TextStyle? style = Theme.of(context).textTheme.bodySmall;
    if (order.clientId == null) {
      return Text(
        '${order.senderName ?? ''}\n${order.externalAddress ?? ''}'.trim(),
        style: style,
      );
    }
    final AsyncValue<Client?> client =
        ref.watch(clientByIdProvider(order.clientId!));
    return client.when(
      data: (Client? c) => Text(
        <String>[
          _date(order.createdAt),
          c?.name ?? '',
          '${c?.street ?? ''}, ${c?.zip ?? ''} ${c?.city ?? ''}'.trim(),
        ].where((String s) => s.isNotEmpty).join(' · '),
        style: style,
      ),
      loading: () => const Text('…'),
      error: (Object e, StackTrace st) => const Text(''),
    );
  }

  Widget _dueDateTile(BuildContext context, Order order) {
    final DateTime? due = order.dueDateStart;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(
        due == null
            ? 'Ausführungsdatum festlegen'
            : 'Ausführungsdatum: ${_date(due)}',
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: due ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked == null) return;
        await ref.read(orderRepositoryProvider).update(
              Order(
                id: order.id,
                clientId: order.clientId,
                title: order.title,
                description: order.description,
                createdAt: order.createdAt,
                dueDateStart: picked,
                dueDateEnd: order.dueDateEnd,
                status: order.status,
                recurring: order.recurring,
                notes: order.notes,
                origin: order.origin,
                packageId: order.packageId,
                externalAddress: order.externalAddress,
                senderName: order.senderName,
              ),
            );
        ref.invalidate(ordersProvider);
      },
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}
