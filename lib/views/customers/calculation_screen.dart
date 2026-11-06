import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/invoice_item.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/invoicing/invoice_calculator.dart';
import 'package:galabau_app/services/invoicing/invoice_flow_service.dart';
import 'package:galabau_app/services/invoicing/invoice_repository.dart';
import 'package:galabau_app/services/invoicing/invoice_service.dart';
import 'package:galabau_app/services/invoicing/number_assigner.dart';
import 'package:galabau_app/services/pdf/invoice_pdf_builder.dart';
import 'package:galabau_app/services/pdf/invoice_pdf_fonts.dart';
import 'package:galabau_app/services/settings/settings_repository.dart';
import 'package:galabau_app/services/storage/einnahmen_xlsx_mapper.dart';
import 'package:galabau_app/services/storage/invoice_storage_service.dart';

/// Kalkulationsrechner des Auftrags (Vision, Abschnitt 4.4).
class CalculationScreen extends ConsumerStatefulWidget {
  const CalculationScreen({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<CalculationScreen> createState() => _CalculationScreenState();
}

class _LineDraft {
  final TextEditingController description = TextEditingController();
  final TextEditingController quantity = TextEditingController();
  final TextEditingController unit = TextEditingController();
  final TextEditingController price = TextEditingController();

  void dispose() {
    description.dispose();
    quantity.dispose();
    unit.dispose();
    price.dispose();
  }
}

class _CalculationScreenState extends ConsumerState<CalculationScreen> {
  final List<_LineDraft> _lines = <_LineDraft>[];
  String? _draftId;
  int _vatRateBp = 1900;
  bool _saving = false;
  String? _suggestedNumber;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final _LineDraft line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final invoiceService = ref.read(invoiceServiceProvider);
    final draft = await invoiceService.draftByOrder(widget.order.id);
    final settings = await ref.read(settingsRepositoryProvider).loadAll();
    final vatBp = int.tryParse(settings['mwst_bp_default'] ?? '') ?? 1900;
    final suggested = await invoiceService.assigner
        .suggestNumber(InvoiceDocumentType.invoice);

    final List<_LineDraft> loadedLines = <_LineDraft>[];
    if (draft != null) {
      final items = await invoiceService.loadItems(draft.id);
      for (final InvoiceItem item in items) {
        final _LineDraft line = _LineDraft();
        line.description.text = item.description;
        line.quantity.text = _milliToText(item.quantityMilli);
        line.unit.text = item.unit;
        line.price.text = _centsToText(item.unitPriceCents);
        loadedLines.add(line);
      }
    }
    if (loadedLines.isEmpty) {
      loadedLines.add(_LineDraft());
    }

    if (!mounted) return;
    setState(() {
      _draftId = draft?.id;
      _vatRateBp = vatBp;
      _suggestedNumber = suggested;
      _lines
        ..clear()
        ..addAll(loadedLines);
    });
  }

  int? _parseMilli(String value) {
    final double? parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed == null ? null : (parsed * 1000).round();
  }

  int? _parseCents(String value) {
    final double? parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed == null ? null : (parsed * 100).round();
  }

  List<InvoiceLineInput>? _parseLines() {
    final List<InvoiceLineInput> lines = <InvoiceLineInput>[];
    for (int i = 0; i < _lines.length; i++) {
      final _LineDraft line = _lines[i];
      final String description = line.description.text.trim();
      if (description.isEmpty) continue;
      final int? milli = _parseMilli(line.quantity.text);
      final int? cents = _parseCents(line.price.text);
      if (milli == null || cents == null) return null;
      lines.add(InvoiceLineInput(
        position: i + 1,
        description: description,
        quantityMilli: milli,
        unit: line.unit.text.trim(),
        unitPriceCents: cents,
      ));
    }
    return lines;
  }

  InvoiceTotals? _totals() {
    final List<int> lineTotals = <int>[];
    for (final _LineDraft line in _lines) {
      final int? milli = _parseMilli(line.quantity.text);
      final int? cents = _parseCents(line.price.text);
      if (milli == null || cents == null) return null;
      lineTotals.add(InvoiceCalculator.lineTotalCents(
        quantityMilli: milli,
        unitPriceCents: cents,
      ));
    }
    return InvoiceCalculator.totals(
      lineTotalsCents: lineTotals,
      vatRateBp: _vatRateBp,
    );
  }

  Future<void> _saveDraft() async {
    final List<InvoiceLineInput>? lines = _parseLines();
    if (lines == null) {
      _snack('Menge und Preis müssen Zahlen sein.');
      return;
    }
    setState(() => _saving = true);
    final saved = await ref.read(invoiceServiceProvider).saveDraft(
          draftId: _draftId,
          clientId: widget.order.clientId,
          orderId: widget.order.id,
          lines: lines,
          vatRateBp: _vatRateBp,
        );
    if (!mounted) return;
    setState(() {
      _draftId = saved.id;
      _saving = false;
    });
    _snack('Kalkulation gespeichert');
  }

  Future<void> _generate(String type) async {
    final List<InvoiceLineInput>? lines = _parseLines();
    if (lines == null || lines.isEmpty) {
      _snack('Bitte mindestens eine Position angeben.');
      return;
    }
    setState(() => _saving = true);
    try {
      final client = await ref
          .read(clientRepositoryProvider)
          .getById(widget.order.clientId);
      if (client == null) {
        _snack('Kunde nicht gefunden.');
        return;
      }
      final settings = await ref.read(settingsRepositoryProvider).loadAll();
      final fonts = await InvoicePdfFonts.load();
      final pdfBuilder = InvoicePdfBuilder(
        regularFont: fonts.regular,
        boldFont: fonts.bold,
      );
      final directory = await getApplicationDocumentsDirectory();
      final flow = InvoiceFlowService(
        invoiceService: ref.read(invoiceServiceProvider),
        storageService: InvoiceStorageService(baseDirectory: directory),
        xlsxMapper: const EinnahmenXlsxMapper(),
      );
      await flow.createAndStore(
        client: client,
        orderTitle: widget.order.title,
        settings: settings,
        lines: lines,
        vatRateBp: _vatRateBp,
        type: type,
        buildPdf: (data) => pdfBuilder.build(data),
      );
      if (!mounted) return;
      ref.invalidate(invoicesByOrderProvider(widget.order.id));
      ref.invalidate(issuedInvoicesProvider);
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _snack('Fehler: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _milliToText(int milli) {
    if (milli % 1000 == 0) return '${milli ~/ 1000}';
    String frac = (milli % 1000).toString().padLeft(3, '0');
    frac = frac.replaceAll(RegExp(r'0+$'), '');
    return '${milli ~/ 1000},$frac';
  }

  String _centsToText(int cents) {
    final int whole = cents ~/ 100;
    final String frac = (cents % 100).toString().padLeft(2, '0');
    return '$whole,$frac';
  }

  String _euro(int? cents) {
    if (cents == null) return '–';
    return _centsToText(cents);
  }

  @override
  Widget build(BuildContext context) {
    final InvoiceTotals? totals = _totals();
    final AsyncValue<Client?> client =
        ref.watch(clientByIdProvider(widget.order.clientId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulation: ${widget.order.title}'),
        actions: <Widget>[
          TextButton(
            onPressed: _saving ? null : _saveDraft,
            child: const Text('Speichern',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          client.when(
            data: (Client? c) => c == null
                ? const SizedBox.shrink()
                : Text('Kunde: ${c.name} · ${c.street}, ${c.zip} ${c.city}'
                    .trim()),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 4),
          Text('Erstellt am: ${_date(widget.order.createdAt)}'),
          const SizedBox(height: 16),
          Text('POSITIONEN',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          for (int i = 0; i < _lines.length; i++) _lineEditor(i),
          TextButton.icon(
            onPressed: () => setState(() => _lines.add(_LineDraft())),
            icon: const Icon(Icons.add),
            label: const Text('Position hinzufügen'),
          ),
          const Divider(),
          Text('GESAMTKALKULATION',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _summaryRow('Summe Netto', _euro(totals?.netCents)),
          _summaryRow(
              'MwSt. (${_vatRateBp ~/ 100} %)', _euro(totals?.vatCents)),
          const Divider(),
          _summaryRow('TOTAL (BRUTTO)', _euro(totals?.grossCents), bold: true),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : () => _generate('offer'),
            icon: const Icon(Icons.request_quote_outlined),
            label: const Text('Als Angebot speichern (PDF)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _saving ? null : () => _generate('invoice'),
            icon: const Icon(Icons.receipt_long),
            label: Text(_suggestedNumber == null
                ? 'Rechnung generieren'
                : 'Rechnung generieren ($_suggestedNumber)'),
          ),
        ],
      ),
    );
  }

  Widget _lineEditor(int index) {
    final _LineDraft line = _lines[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: line.description,
                    decoration: const InputDecoration(labelText: 'Bezeichnung'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    line.dispose();
                    _lines.removeAt(index);
                  }),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: line.quantity,
                    decoration: const InputDecoration(labelText: 'Menge'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: line.unit,
                    decoration: const InputDecoration(labelText: 'Einheit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: line.price,
                    decoration: const InputDecoration(labelText: 'EP (€)'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}