import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/work/work_media_service.dart';

void main() {
  late Directory tempDir;
  late WorkMediaService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('work_media_test');
    service = WorkMediaService(baseDirectory: tempDir);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('saveMedia legt Datei im Auftragsordner ab', () async {
    final String path = await service.saveMedia(
      orderTitle: 'Laubentfernung',
      subfolder: 'fotos',
      fileName: '1.jpg',
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final File file = File(path);
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync(), <int>[1, 2, 3]);
    expect(
      path,
      contains('Aufträge${Platform.pathSeparator}Laubentfernung'
          '${Platform.pathSeparator}Arbeitsdokumentation'
          '${Platform.pathSeparator}fotos'),
    );
  });

  test('saveMedia erstellt Unterordner für Sprachmemos', () async {
    final String path = await service.saveMedia(
      orderTitle: 'Baumschnitt',
      subfolder: 'sprachmemos',
      fileName: 'memo.m4a',
      bytes: Uint8List.fromList(<int>[4, 5, 6]),
    );

    expect(File(path).existsSync(), isTrue);
    expect(path, contains('sprachmemos'));
  });
}
