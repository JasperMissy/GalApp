import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/invoicing/invoice_calculator.dart';

void main() {
  group('InvoiceCalculator.lineTotalCents', () {
    test('1,5 h x 65,00 EUR = 97,50 EUR', () {
      expect(
        InvoiceCalculator.lineTotalCents(
          quantityMilli: 1500,
          unitPriceCents: 6500,
        ),
        9750,
      );
    });

    test('18 Stück x 65,00 EUR = 1.170,00 EUR', () {
      expect(
        InvoiceCalculator.lineTotalCents(
          quantityMilli: 18000,
          unitPriceCents: 6500,
        ),
        117000,
      );
    });

    test('Rundung: 33,3 Cent auf 33 Cent abrunden', () {
      expect(
        InvoiceCalculator.lineTotalCents(
          quantityMilli: 333,
          unitPriceCents: 100,
        ),
        33,
      );
    });

    test('Rundung: 99,9 Cent auf 100 Cent aufrunden (roundHalfUp)', () {
      expect(
        InvoiceCalculator.lineTotalCents(
          quantityMilli: 999,
          unitPriceCents: 100,
        ),
        100,
      );
    });

    test('Rundung: exakt 12,5 Cent auf 13 Cent (halbe aufrunden)', () {
      expect(
        InvoiceCalculator.lineTotalCents(
          quantityMilli: 125,
          unitPriceCents: 100,
        ),
        13,
      );
    });
  });

  group('InvoiceCalculator.totals', () {
    test('Netto, MwSt (19 %) und Brutto', () {
      final totals = InvoiceCalculator.totals(
        lineTotalsCents: [117000, 9750],
        vatRateBp: 1900,
      );
      expect(totals.netCents, 126750);
      expect(totals.vatCents, 24083); // 1267,50 EUR x 19 % = 24082,5 Cent -> 24083 Cent
      expect(totals.grossCents, 150833);
    });

    test('MwSt-Rundung an der Halbe-Grenze', () {
      // netto 100,03 EUR x 19 % = 19,0057 EUR -> 19,01 EUR
      final totals = InvoiceCalculator.totals(
        lineTotalsCents: [10003],
        vatRateBp: 1900,
      );
      expect(totals.vatCents, 1901);
      expect(totals.grossCents, 11904);
    });

    test('MwSt 7 %', () {
      final totals = InvoiceCalculator.totals(
        lineTotalsCents: [10000],
        vatRateBp: 700,
      );
      expect(totals.vatCents, 700);
      expect(totals.grossCents, 10700);
    });

    test('Leere Positionen: alles null', () {
      final totals = InvoiceCalculator.totals(
        lineTotalsCents: const [],
        vatRateBp: 1900,
      );
      expect(totals.netCents, 0);
      expect(totals.vatCents, 0);
      expect(totals.grossCents, 0);
    });
  });
}