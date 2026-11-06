import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/client.dart' as model;
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/invoicing/invoice_flow_service.dart';
import 'package:galabau_app/services/invoicing/invoice_service.dart';
import 'package:galabau_app/services/invoicing/number_assigner.dart';
import 'package:galabau_app/services/storage/einnahmen_xlsx_mapper.dart';
import 'package:galabau_app/services/storage/invoice_storage_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase db;
  late InvoiceService invoiceService;
  late Directory temp;
  late InvoiceStorageService storage;
  late InvoiceFlowService flow;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    invoiceService = InvoiceService(db: db, assigner: NumberAssigner(db: db));
    temp = Directory.systemTemp.createTempSync('galabau_flow_test');
    storage = InvoiceStorageService(baseDirectory: temp);
    flow = InvoiceFlowService(
      invoiceService: invoiceService,
      storageService: storage,
      xlsxMapper: const EinnahmenXlsxMapper(),
    );
  });

  tearDown(() async {
    await db.close();
    temp.deleteSync(recursive: true);
  });

  test('createAndStore legt Rechnung, PDF und Einnahmen.xlsx an', () async {
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'k-1', name: 'Berger', createdAt: DateTime(2026),
        ));

    final invoice = await flow.createAndStore(
      client: model.Client(
        id: 'k-1',
        name: 'Berger',
        street: 'Weg 1',
        zip: '34123',
        city: 'Kassel',
        phone: '',
        email: '',
        createdAt: DateTime(2026),
      ),
      orderTitle: 'Laubentfernung',
      settings: const {'firmenname': 'Grünes GaLaBau', 'akzentfarbe': '#2E7D32'},
      lines: const <InvoiceLineInput>[
        InvoiceLineInput(position: 1, description: 'Laub', quantityMilli: 18000, unit: 'Std.', unitPriceCents: 6500),
      ],
      vatRateBp: 1900,
      buildPdf: (data) async => Uint8List.fromList([1, 2, 3]),
      issuedDate: DateTime(2026, 11, 5),
    );

    expect(invoice.number, 'RE-2026-0001');

    final pdfFile = File(p.join(temp.path, 'Aufträge', 'Laubentfernung',
        'Rechnungen', 'RE-2026-0001.pdf'));
    expect(pdfFile.existsSync(), isTrue);
    expect(pdfFile.readAsBytesSync(), [1, 2, 3]);

    final xlsxBytes = await storage.readEinnahmenXlsx();
    expect(xlsxBytes, isNotNull);
    final excel = Excel.decodeBytes(xlsxBytes!);
    final rows = excel[excel.getDefaultSheet()!].rows;
    expect(rows.length, 2);
    final last = rows.last.map((cell) {
      final value = cell?.value;
      return value is TextCellValue ? value.value.text ?? '' : '';
    }).toList();
    expect(last[4], 'RE-2026-0001');
  });
}