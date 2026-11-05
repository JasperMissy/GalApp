import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/storage/einnahmen_xlsx_mapper.dart';

void main() {
  final row = EinnahmenXlsxRow(
    datum: DateTime(2026, 11, 5),
    kundenname: 'Familie Möller',
    adresse: 'Am Wiesengrund 5, 34123 Kassel',
    auftragstitel: 'Laubentfernung',
    rechnungsnummer: 'RE-2026-0001',
    summeBruttoCents: 150833,
    summeNettoCents: 126750,
  );

  test('neue Datei erzeugt Header und eine Datenzeile', () {
    final bytes =
        const EinnahmenXlsxMapper().appendRow(existingBytes: null, row: row);

    final excel = Excel.decodeBytes(bytes);
    final rows = excel[excel.getDefaultSheet()!].rows;

    expect(rows.length, 2);
    expect(_texts(rows.first), EinnahmenXlsxMapper.headers);
    expect(_texts(rows.last), [
      '05.11.2026',
      'Familie Möller',
      'Am Wiesengrund 5, 34123 Kassel',
      'Laubentfernung',
      'RE-2026-0001',
      '1508,33',
      '1267,50',
    ]);
  });

  test('append-only: bestehende Datei erhält eine zusätzliche Zeile', () {
    final first =
        const EinnahmenXlsxMapper().appendRow(existingBytes: null, row: row);

    final secondRow = EinnahmenXlsxRow(
      datum: DateTime(2026, 11, 6),
      kundenname: 'Familie Möller',
      adresse: 'Am Wiesengrund 5, 34123 Kassel',
      auftragstitel: 'Baumschnitt',
      rechnungsnummer: 'RE-2026-0002',
      summeBruttoCents: 11900,
      summeNettoCents: 10000,
    );

    final second = const EinnahmenXlsxMapper()
        .appendRow(existingBytes: first, row: secondRow);

    final excel = Excel.decodeBytes(second);
    final rows = excel[excel.getDefaultSheet()!].rows;

    expect(rows.length, 3);
    expect(_texts(rows.first), EinnahmenXlsxMapper.headers);
    expect(_texts(rows.last)[4], 'RE-2026-0002');
  });
}

List<String> _texts(List<Data?> row) {
  final result = <String>[];
  for (final cell in row) {
    final value = cell?.value;
    if (value is TextCellValue) {
      result.add(value.value.text ?? '');
    } else {
      result.add('');
    }
  }
  return result;
}
