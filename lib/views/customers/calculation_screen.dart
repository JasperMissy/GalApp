import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:galabau_app/services/settings/settings_keys.dart';
import 'package:galabau_app/services/settings/settings_repository.dart';
import 'package:galabau_app/services/storage/einnahmen_xlsx_mapper.dart';
import 'package:galabau_app/services/storage/invoice_storage_service.dart';

/// Kalkulationsrechner eines Auftrags: leere Tabelle, Positionen über einen
/// „Feld-Modus“ (Bottom-Sheet) hinzufügen, Live-Summen inkl. Kleinunternehmer.
class CalculationScreen extends ConsumerStatefulWidget {
  const CalculationScreen({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<CalculationScreen> createState() => _CalculationScreenState();
}

/// Eine bereits erfasste Position (wird als Textzeile angezeigt).
class _Position {
  const _Position({
    required this.description,
    required this.quantityMilli,
    required this.unit,
    required this.unitPriceCents,
  });

  final String description;
  final int quantityMilli;
  final String unit;
  final int unitPriceCents;

  int get totalCents => InvoiceCalculator.lineTotalCents(
        quantityMilli: quantityMilli,
        unitPriceCents: unitPriceCents,
      );
}

/// Ergebnis des „Feld-Modus“ (eingegebene, noch nicht gespeicherte Position).
class _PositionInput {
  const _PositionInput({
    required this.description,
    required this.quantityMilli,
    required this.unit,
    required this.unitPriceCents,
  });

  final String description;
  final int quantityMilli;
  final String unit;
  final int unitPriceCents;
}

class _CalculationScreenState extends ConsumerState<CalculationScreen> {
  final List<_Position> _positions = <_Position>[];

  String? _draftId;
  int _vatRateBp = 1900;
  bool _isKleinunternehmer = false;
  bool _loading = true;
  bool _saving = false;
  String? _suggestedNumber;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final InvoiceService invoiceService = ref.read(invoiceServiceProvider);
    final Map<String, String> settings =
        await ref.read(settingsRepositoryProvider).loadAll();

    final int defaultVat =
        int.tryParse(settings['mwst_bp_default'] ?? '') ?? 1900;
    final bool kleinunternehmer =
        (settings[SettingsKeys.kleinunternehmer] ?? 'nein') == 'ja';
    final String suggested =
        await invoiceService.assigner.suggestNumber(InvoiceDocumentType.invoice);

    final draft = await invoiceService.draftByOrder(widget.order.id);
    final List<_Position> loaded = <_Position>[];
    if (draft != null) {
      final List<InvoiceItem> items = await invoiceService.loadItems(draft.id);
      for (final InvoiceItem item in items) {
        loaded.add(_Position(
          description: item.description,
          quantityMilli: item.quantityMilli,
          unit: item.unit,
          unitPriceCents: item.unitPriceCents,
        ));
      }
    }

    if (!mounted) return;
    setState(() {
      _draftId = draft?.id;
      _isKleinunternehmer = kleinunternehmer;
      _vatRateBp = kleinunternehmer ? 0 : defaultVat;
      _suggestedNumber = suggested;
      _positions
        ..clear()
        ..addAll(loaded);
      _loading = false;
    });
  }

  InvoiceTotals _totals() => InvoiceCalculator.totals(
        lineTotalsCents: _positions.map((p) => p.totalCents).toList(),
        vatRateBp: _vatRateBp,
      );

  List<InvoiceLineInput> _toLines() {
    final List<InvoiceLineInput> lines = <InvoiceLineInput>[
      for (int i = 0; i < _positions.length; i++)
        InvoiceLineInput(
          position: i + 1,
          description: _positions[i].description,
          quantityMilli: _positions[i].quantityMilli,
          unit: _positions[i].unit,
          unitPriceCents: _positions[i].unitPriceCents,
        ),
    ];
    return lines;
  }

  Future<void> _persist() async {
    final String? clientId = widget.order.clientId;
    if (clientId == null) return;
    final saved = await ref.read(invoiceServiceProvider).saveDraft(
          draftId: _draftId,
          clientId: clientId,
          orderId: widget.order.id,
          lines: _toLines(),
          vatRateBp: _vatRateBp,
        );
    if (!mounted) return;
    setState(() => _draftId = saved.id);
  }

  Future<void> _openAddSheet() async {
    final _PositionInput? input = await showModalBottomSheet<_PositionInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddPositionSheet(),
    );
    if (input == null || !mounted) return;

    setState(() => _saving = true);
    setState(() => _positions.add(_Position(
          description: input.description,
          quantityMilli: input.quantityMilli,
          unit: input.unit,
          unitPriceCents: input.unitPriceCents,
        )));
    await _persist();
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _removeAt(int index) async {
    setState(() => _saving = true);
    setState(() => _positions.removeAt(index));
    await _persist();
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _generate(String type) async {
    final List<InvoiceLineInput> lines = _toLines();
    if (lines.isEmpty) {
      _snack('Bitte mindestens eine Position angeben.');
      return;
    }
    final String? clientId = widget.order.clientId;
    if (clientId == null) {
      _snack('Für diesen Auftrag ist kein Kunde hinterlegt.');
      return;
    }
    setState(() => _saving = true);
    try {
      final Client? client =
          await ref.read(clientRepositoryProvider).getById(clientId);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final ThemeData theme = Theme.of(context);
    final InvoiceTotals totals = _totals();
    final bool hasClient = widget.order.clientId != null;

    return Scaffold(
      appBar: AppBar(title: Text('Kalkulation: ${widget.order.title}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (_saving || !hasClient) ? null : _openAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Position'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: <Widget>[
          _headerCard(theme, totals),
          const SizedBox(height: 16),
          if (!hasClient) _noClientCard(theme),
          if (!hasClient) const SizedBox(height: 8),
          _tableCard(theme),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed:
                (_saving || !hasClient) ? null : () => _generate('offer'),
            icon: const Icon(Icons.request_quote_outlined),
            label: const Text('Als Angebot speichern (PDF)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed:
                (_saving || !hasClient) ? null : () => _generate('invoice'),
            icon: const Icon(Icons.receipt_long),
            label: Text(_suggestedNumber == null
                ? 'Rechnung generieren'
                : 'Rechnung generieren ($_suggestedNumber)'),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(ThemeData theme, InvoiceTotals totals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.calculate_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Summen',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (_isKleinunternehmer)
                  Chip(
                    avatar: const Icon(Icons.check, size: 16),
                    label: const Text('Kleinunternehmer §19 UStG'),
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _sumTile(theme, 'Netto', totals.netCents),
                _sumTile(theme, 'MwSt.', totals.vatCents,
                    sub: _isKleinunternehmer ? 'kein Ausweis' : null),
                _sumTile(theme, 'Brutto', totals.grossCents, emphasize: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumTile(ThemeData theme, String label, int cents,
      {String? sub, bool emphasize = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            _euro(cents),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: emphasize ? theme.colorScheme.primary : null,
            ),
          ),
          if (sub != null) Text(sub, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _noClientCard(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.info_outline, color: theme.colorScheme.error),
        title: const Text('Kein Kunde hinterlegt'),
        subtitle: const Text(
            'Zum Speichern und Abrechnen muss dem Auftrag ein Kunde '
            'zugeordnet sein.'),
      ),
    );
  }

  Widget _tableCard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Positionen',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_positions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: <Widget>[
                  Icon(Icons.inbox_outlined,
                      size: 48, color: theme.colorScheme.secondary),
                  const SizedBox(height: 12),
                  Text('Noch keine Positionen',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Tippe unten rechts auf „+ Position“, um die erste '
                    'Position hinzuzufügen.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: <Widget>[
                for (int i = 0; i < _positions.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: Colors.grey.shade200),
                  _positionTile(theme, i),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _positionTile(ThemeData theme, int index) {
    final _Position p = _positions[index];
    return ListTile(
      title: Text(p.description,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
          '${_formatQuantity(p.quantityMilli)} ${p.unit} × '
          '${_euro(p.unitPriceCents)}/${p.unit}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(_euro(p.totalCents),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: theme.colorScheme.error,
            tooltip: 'Position löschen',
            onPressed: _saving ? null : () => _removeAt(index),
          ),
        ],
      ),
    );
  }
}

// „Feld-Modus“: Bottom-Sheet zum Erfassen einer Position.
class _AddPositionSheet extends StatefulWidget {
  const _AddPositionSheet();

  @override
  State<_AddPositionSheet> createState() => _AddPositionSheetState();
}

class _AddPositionSheetState extends State<_AddPositionSheet> {
  final TextEditingController _description = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _unit = TextEditingController(text: 'Stück');
  final TextEditingController _price = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    _quantity.dispose();
    _unit.dispose();
    _price.dispose();
    super.dispose();
  }

  int? _sum() {
    final int? milli = _parseMilli(_quantity.text);
    final int? cents = _parseCents(_price.text);
    if (milli == null || cents == null) return null;
    return InvoiceCalculator.lineTotalCents(
      quantityMilli: milli,
      unitPriceCents: cents,
    );
  }

  void _submit() {
    final String description = _description.text.trim();
    final int? milli = _parseMilli(_quantity.text);
    final int? cents = _parseCents(_price.text);
    if (description.isEmpty || milli == null || cents == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bitte Bezeichnung, Einzelpreis und Menge angeben.')));
      return;
    }
    Navigator.of(context).pop(_PositionInput(
      description: description,
      quantityMilli: milli,
      unit: _unit.text.trim().isEmpty ? 'Stück' : _unit.text.trim(),
      unitPriceCents: cents,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int? sum = _sum();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Neue Position',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: _description,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Bezeichnung',
                hintText: 'z. B. Arbeitszeit, Entsorgungspauschale',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Einzelpreis (€)',
                      hintText: 'z. B. 65,00',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  child: TextField(
                    controller: _unit,
                    decoration: const InputDecoration(labelText: 'Einheit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _quantity,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Menge / Faktor',
                      hintText: 'z. B. 12',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  sum == null ? 'Summe: –' : 'Summe: ${_euro(sum)}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: const Text('Position hinzufügen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Formatierung (geteilt zwischen Screen und Sheet)
// -----------------------------------------------------------------------------

String _euro(int cents) {
  final bool negative = cents < 0;
  final int abs = cents.abs();
  final String whole = (abs ~/ 100).toString();
  final String frac = (abs % 100).toString().padLeft(2, '0');
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write('.');
    buf.write(whole[i]);
  }
  return '${negative ? '-' : ''}$buf,$frac €';
}

String _formatQuantity(int milli) {
  if (milli % 1000 == 0) return '${milli ~/ 1000}';
  String frac = (milli % 1000).toString().padLeft(3, '0');
  frac = frac.replaceAll(RegExp(r'0+$'), '');
  return '${milli ~/ 1000},$frac';
}

int? _parseMilli(String value) {
  final double? d = double.tryParse(value.replaceAll(',', '.'));
  return d == null ? null : (d * 1000).round();
}

int? _parseCents(String value) {
  final double? d = double.tryParse(value.replaceAll(',', '.'));
  return d == null ? null : (d * 100).round();
}
