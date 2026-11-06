import 'dart:typed_data';

import '../../models/client.dart';
import '../../models/invoice.dart' as model;
import '../pdf/invoice_pdf_builder.dart';
import '../pdf/invoice_pdf_mapper.dart';
import '../storage/einnahmen_xlsx_mapper.dart';
import '../storage/invoice_storage_service.dart';
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
    final model.Invoice invoice = await invoiceService.createInvoice(
      clientId: client.id,
      lines: lines,
      vatRateBp: vatRateBp,
      type: type,
      number: number,
      issuedDate: issuedDate,
    );

    final items = await invoiceService.loadItems(invoice.id);
    final InvoicePdfData data = InvoicePdfMapper.map(
      invoice: invoice,
      items: items,
      client: client,
      settings: settings,
    );
    final Uint8List bytes = await buildPdf(data);
    await storageService.saveInvoicePdf(
      orderTitle: orderTitle,
      fileName: '${invoice.number}.pdf',
      pdfBytes: bytes,
    );

    if (type == 'invoice') {
      await _appendEinnahmen(invoice, client, orderTitle);
    }
    return invoice;
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