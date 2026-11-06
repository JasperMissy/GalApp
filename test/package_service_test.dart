import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/package_manifest.dart';
import 'package:galabau_app/services/packages/package_service.dart';

void main() {
  const PackageService service = PackageService();

  test('Paket schreiben und lesen (Roundtrip)', () {
    final PackageManifest manifest = PackageManifest(
      id: 'pkg-1',
      type: 'auftrag',
      title: 'Laubentfernung',
      address: 'Musterweg 1, 34123 Kassel',
      description: 'Vorgarten inkl. Abtransport',
      senderName: 'Chef GmbH',
    );

    final Uint8List bytes = service.createPackage(
      manifest: manifest,
      files: <String, Uint8List>{
        'fotos/1.jpg': Uint8List.fromList(<int>[1, 2, 3]),
      },
    );

    expect(bytes, isNotEmpty);

    final PackageContent? content = service.readPackage(bytes);
    expect(content, isNotNull);
    expect(content!.manifest.id, 'pkg-1');
    expect(content.manifest.type, 'auftrag');
    expect(content.manifest.title, 'Laubentfernung');
    expect(content.manifest.senderName, 'Chef GmbH');
    expect(content.files['fotos/1.jpg'], <int>[1, 2, 3]);
  });

  test('Rechnungs-Metadaten überleben den Roundtrip', () {
    final PackageManifest manifest = PackageManifest(
      id: 'pkg-2',
      type: 'rechnung',
      title: 'Baumschnitt',
      address: '',
      description: '',
      senderName: 'Sub GmbH',
      invoiceNumber: 'RE-2026-0001',
      netCents: 10000,
      grossCents: 11900,
    );

    final PackageContent? content = service.readPackage(
      service.createPackage(manifest: manifest),
    );

    expect(content, isNotNull);
    expect(content!.manifest.type, 'rechnung');
    expect(content.manifest.invoiceNumber, 'RE-2026-0001');
    expect(content.manifest.netCents, 10000);
    expect(content.manifest.grossCents, 11900);
  });
}
