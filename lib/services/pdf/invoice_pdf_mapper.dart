import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import 'invoice_pdf_builder.dart';

/// Konvertiert Domain-Models in das Generatorformat [InvoicePdfData].
///
/// Firmen-Stammdaten und Design-Optionen kommen aus [settings]
/// (Schlüssel siehe `docs/Architektur-Rechnungswesen.md`, Abschnitt 3).
abstract final class InvoicePdfMapper {
  static InvoicePdfData map({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required Client client,
    required Map<String, String> settings,
  }) {
    final number = invoice.number;
    if (number == null || number.isEmpty) {
      throw ArgumentError.value(
        invoice.number,
        'invoice.number',
        'Eine Rechnung ohne Nummer kann nicht als PDF ausgegeben werden.',
      );
    }

    final sorted = [...items]..sort((a, b) => a.position.compareTo(b.position));

    return InvoicePdfData(
      companyName: settings['firmenname'] ?? '',
      companyStreet: settings['strasse'] ?? '',
      companyZipCity: _zipCity(settings['plz'], settings['ort']),
      companyPhone: settings['telefon'] ?? '',
      companyEmail: settings['email'] ?? '',
      taxNumber: settings['steuernummer'] ?? '',
      ustId: settings['ust_id'] ?? '',
      iban: settings['iban'] ?? '',
      accentColorHex: settings['akzentfarbe'] ?? '#4CAF50',
      clientName: client.name,
      clientStreet: client.street,
      clientZipCity: _zipCity(client.zip, client.city),
      number: number,
      issueDate: invoice.issuedDate ?? invoice.createdAt,
      lines: sorted
          .map((item) => InvoicePdfLine(
                position: item.position,
                description: item.description,
                quantityMilli: item.quantityMilli,
                unit: item.unit,
                unitPriceCents: item.unitPriceCents,
                totalCents: item.totalCents,
              ))
          .toList(),
      netCents: invoice.netCents,
      vatRateBp: invoice.vatRateBp,
      vatCents: invoice.vatCents,
      grossCents: invoice.grossCents,
      footerText: settings['layout.fusszeile_text'],
      // logo_pfad wird erst mit der Asset-/Datei-Einbindung im UI-Schritt
      // aufgelöst; bis dahin bleibt das Logo leer (logoBytes = null).
    );
  }

  static String _zipCity(String? zip, String? city) {
    final z = (zip ?? '').trim();
    final c = (city ?? '').trim();
    if (z.isEmpty) return c;
    if (c.isEmpty) return z;
    return '$z $c';
  }
}