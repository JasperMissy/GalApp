import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/storage/invoice_storage_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temp;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('galabau_storage_test');
  });

  tearDown(() {
    temp.deleteSync(recursive: true);
  });

  test('legt PDF im Auftragsordner ab', () async {
    final service = InvoiceStorageService(baseDirectory: temp);
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    final path = await service.saveInvoicePdf(
      orderTitle: 'Laubentfernung',
      fileName: 'RE-2026-0001.pdf',
      pdfBytes: bytes,
    );

    final expected = p.join(temp.path, 'Aufträge', 'Laubentfernung',
        'Rechnungen', 'RE-2026-0001.pdf');
    expect(path, expected);

    final file = File(expected);
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync(), bytes);
  });
}