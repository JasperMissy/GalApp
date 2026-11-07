import 'dart:io';
import 'dart:typed_data';

import '../../models/client.dart';
import '../../models/invoice.dart' as model;
import '../../models/invoice_item.dart' as item;
import '../pdf/invoice_pdf_builder.dart';
import '../pdf/invoice_pdf_mapper.dart';
import '../storage/einnahmen_xlsx_mapper.dart';
import '../storage/invoice_storage_service.dart';
import 'invoice_calculator.dart';
import 'invoice_service.dart';

/// Orchestriert den Speicher-Flow einer Rechnung: anlegen, PDF erzeugen,
/// im Auftragsordner ablegen und `Einnahmen.xlsx`-Zeile anhängen.
class InvoiceFlowService {
  const InvoiceFlowService({
    required this.invoiceService,
    required this.storageService,
    required this.xlsxMapper,
  });

  final InvoiceService invoiceService;
  final InvoiceStorageService storageService;
  final EinnahmenXlsxMapper xlsxMapper;

  Future<model.Invoice> createAndStore({
    required Client client,
    required String orderTitle,
    required Map<String, String> settings,
    required List<InvoiceLineInput> lines,
    required int vatRateBp,
    String type = 'invoice',
    required Future<Uint8List> Function(InvoicePdfData data) buildPdf,
    String? number,
    DateTime? issuedDate,
  }) async {
    final DateTime date = issuedDate ?? DateTime.now();

    // 1. Nummer reservieren und Summen berechnen, damit das PDF vor dem
    //    Datenbank-Commit erzeugt werden kann.
    final String resolvedNumber =
        number ?? await invoiceService.reserveNumber(type, date: date);

    final List<int> lineTotals = <int>[
      for (final InvoiceLineInput line in lines)
        InvoiceCalculator.lineTotalCents(
          quantityMilli: line.quantityMilli,
          unitPriceCents: line.unitPriceCents,
        ),
    ];
    final InvoiceTotals totals = InvoiceCalculator.totals(
      lineTotalsCents: lineTotals,
      vatRateBp: vatRateBp,
    );

    // 2. Transientes Modell nur für die PDF-Erzeugung (noch nicht in der DB).
    final model.Invoice preview = model.Invoice(
      id: '',
      number: resolvedNumber,
      type: type,
      clientId: client.id,
      orderId: null,
      status: 'issued',
      issuedDate: date,
      netCents: totals.netCents,
      vatRateBp: vatRateBp,
      vatCents: totals.vatCents,
      grossCents: totals.grossCents,
      createdAt: date,
    );
    final List<item.InvoiceItem> previewItems = <item.InvoiceItem>[
      for (int i = 0; i < lines.length; i++)
        item.InvoiceItem(
          id: '',
          invoiceId: '',
          position: lines[i].position,
          description: lines[i].description,
          quantityMilli: lines[i].quantityMilli,
          unit: lines[i].unit,
          unitPriceCents: lines[i].unitPriceCents,
          totalCents: lineTotals[i],
        ),
    ];

    // 3. PDF erzeugen und atomar schreiben (temporäre Datei + Umbenennen).
    final InvoicePdfData data = InvoicePdfMapper.map(
      invoice: preview,
      items: previewItems,
      client: client,
      settings: settings,
    );
    final Uint8List bytes = await buildPdf(data);
    final String savedPath = await storageService.saveInvoicePdf(
      orderTitle: orderTitle,
      fileName: '$resolvedNumber.pdf',
      pdfBytes: bytes,
    );

    // 4. Rechnung + Positionen atomar in der Datenbank anlegen. Schlägt das
    //    fehl, wird die bereits geschriebene PDF-Datei wieder entfernt.
    final model.Invoice invoice;
    try {
      invoice = await invoiceService.createInvoice(
        clientId: client.id,
        lines: lines,
        vatRateBp: vatRateBp,
        type: type,
        number: resolvedNumber,
        issuedDate: date,
      );
    } catch (_) {
      await _deleteIfExists(savedPath);
      rethrow;
    }

    if (type == 'invoice') {
      await _appendEinnahmen(invoice, client, orderTitle);
    }
    return invoice;
  }

  Future<void> _deleteIfExists(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _appendEinnahmen(
    model.Invoice invoice,
    Client client,
    String orderTitle,
  ) async {
    final Uint8List? existing = await storageService.readEinnahmenXlsx();
    final EinnahmenXlsxRow row = EinnahmenXlsxRow(
      datum: invoice.issuedDate ?? invoice.createdAt,
      kundenname: client.name,
      adresse: '${client.street} ${client.zip} ${client.city}'.trim(),
      auftragstitel: orderTitle,
      rechnungsnummer: invoice.number ?? '',
      summeBruttoCents: invoice.grossCents,
      summeNettoCents: invoice.netCents,
    );
    final Uint8List updated = xlsxMapper.appendRow(
      existingBytes: existing,
      row: row,
    );
    await storageService.saveEinnahmenXlsx(updated);
  }
}