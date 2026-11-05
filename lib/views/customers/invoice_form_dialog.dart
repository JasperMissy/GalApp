import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/services/invoicing/invoice_calculator.dart';
import 'package:galabau_app/services/invoicing/invoice_service.dart';
import 'package:galabau_app/services/invoicing/number_assigner.dart';

/// Formular zum Erstellen einer Rechnung aus einem Auftrag.
class InvoiceFormDialog extends ConsumerStatefulWidget {
  const InvoiceFormDialog({
    super.key,
    required this.clientId,
    this.orderId,
  });

  final String clientId;
  final String? orderId;

  @override
  ConsumerState<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
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

class _InvoiceFormDialogState extends ConsumerState<InvoiceFormDialog> {
  final TextEditingController _number = TextEditingController();
  final List<_LineDraft> _lines = <_LineDraft>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _lines.add(_LineDraft());
    _loadSuggestedNumber();
  }

  Future<void> _loadSuggestedNumber() async {
    final db = ref.read(invoiceServiceProvider);
    final suggested =
        await db.assigner.suggestNumber(InvoiceDocumentType.invoice);
    if (mounted) _number.text = suggested;
  }

  @override
  void dispose() {
    _number.dispose();
    for (final _LineDraft line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  int? _parseMilli(String value) {
    final double? parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed == null ? null : (parsed * 1000).round();
  }

  int? _parseCents(String value) {
    final double? parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed == null ? null : (parsed * 100).round();
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
    return InvoiceCalculator.totals(lineTotalsCents: lineTotals, vatRateBp: 1900);
  }

  Future<void> _save() async {
    final List<InvoiceLineInput> lines = <InvoiceLineInput>[];
    for (int i = 0; i < _lines.length; i++) {
      final _LineDraft line = _lines[i];
      final String description = line.description.text.trim();
      if (description.isEmpty) continue;
      final int? milli = _parseMilli(line.quantity.text);
      final int? cents = _parseCents(line.price.text);
      if (milli == null || cents == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menge und Preis müssen Zahlen sein.')),
        );
        return;
      }
      lines.add(InvoiceLineInput(
        position: i + 1,
        description: description,
        quantityMilli: milli,
        unit: line.unit.text.trim(),
        unitPriceCents: cents,
      ));
    }

    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mindestens eine Position angeben.')),
      );
      return;
    }

    setState(() => _saving = true);
    await ref.read(invoiceServiceProvider).createInvoice(
          clientId: widget.clientId,
          orderId: widget.orderId,
          lines: lines,
          vatRateBp: 1900,
          number: _number.text.trim().isEmpty ? null : _number.text.trim(),
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final InvoiceTotals? totals = _totals();

    return AlertDialog(
      title: const Text('Rechnung erstellen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _number,
              decoration: const InputDecoration(labelText: 'Rechnungsnummer'),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < _lines.length; i++) _lineEditor(i),
            TextButton.icon(
              onPressed: () => setState(() => _lines.add(_LineDraft())),
              icon: const Icon(Icons.add),
              label: const Text('Position hinzufügen'),
            ),
            const Divider(),
            Text('Netto: ${_euro(totals?.netCents)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('MwSt (19 %): ${_euro(totals?.vatCents)}'),
            Text('TOTAL: ${_euro(totals?.grossCents)}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Erstellen'),
        ),
      ],
    );
  }

  Widget _lineEditor(int index) {
    final _LineDraft line = _lines[index];
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: TextField(
                controller: line.description,
                decoration: const InputDecoration(labelText: 'Bezeichnung'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => setState(() {
                line.dispose();
                _lines.removeAt(index);
              }),
              icon: const Icon(Icons.close),
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
        const SizedBox(height: 12),
      ],
    );
  }

  String _euro(int? cents) {
    if (cents == null) return '–';
    final int whole = cents ~/ 100;
    final String frac = (cents % 100).toString().padLeft(2, '0');
    return '$whole,$frac';
  }
}