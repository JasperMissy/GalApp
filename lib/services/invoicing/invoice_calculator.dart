/// Centgenaue Rechenlogik für Rechnungen und Angebote
/// (docs/Architektur-Rechnungswesen.md, Abschnitt 5).
library;

/// Ergebnis der Summenberechnung in Integer-Cent.
class InvoiceTotals {
  const InvoiceTotals({
    required this.netCents,
    required this.vatRateBp,
    required this.vatCents,
    required this.grossCents,
  });

  final int netCents;
  final int vatRateBp;
  final int vatCents;
  final int grossCents;
}

/// Reine, zustandslose Berechnungsfunktionen ohne Datenbank- oder
/// UI-Abhängigkeit. Alle Beträge in Integer-Cent, MwSt in Basispunkten
/// (1900 = 19 %).
abstract final class InvoiceCalculator {
  /// Zeilensumme: `roundHalfUp(quantity_milli * unit_price_cents / 1000)`.
  ///
  /// Bewusst als Ganzzahlarithmetik implementiert, damit keine
  /// Gleitkommafehler entstehen: `(x + 500) ~/ 1000` ist exakt die
  /// kaufmännische Rundung von `x / 1000` für positive x.
  static int lineTotalCents({
    required int quantityMilli,
    required int unitPriceCents,
  }) =>
      (quantityMilli * unitPriceCents + 500) ~/ 1000;

  /// Netto, MwSt und Brutto über mehrere Positionen.
  ///
  /// - Netto: `net = Σ total_cents`
  /// - MwSt: `vat = roundHalfUp(net * vat_rate_bp / 10000)`
  /// - Brutto: `gross = net + vat`
  static InvoiceTotals totals({
    required List<int> lineTotalsCents,
    required int vatRateBp,
  }) {
    final net =
        lineTotalsCents.fold<int>(0, (sum, lineCents) => sum + lineCents);
    final vat = (net * vatRateBp + 5000) ~/ 10000;
    return InvoiceTotals(
      netCents: net,
      vatRateBp: vatRateBp,
      vatCents: vat,
      grossCents: net + vat,
    );
  }
}