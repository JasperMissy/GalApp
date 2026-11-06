import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../models/package_manifest.dart';

/// Inhalt eines gelesenen `.galabau`-Pakets.
class PackageContent {
  const PackageContent({required this.manifest, required this.files});

  final PackageManifest manifest;

  /// Dateiname (z. B. `fotos/1.jpg`) → Bytes.
  final Map<String, Uint8List> files;
}

/// Erstellt und liest `.galabau`-ZIP-Pakete (Subunternehmer-Workflow).
class PackageService {
  const PackageService();

  /// Baut ein ZIP-Paket aus [manifest] und optionalen [files].
  Uint8List createPackage({
    required PackageManifest manifest,
    Map<String, Uint8List> files = const <String, Uint8List>{},
  }) {
    final Archive archive = Archive();
    final List<int> manifestBytes = utf8.encode(jsonEncode(manifest.toJson()));
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    for (final MapEntry<String, Uint8List> entry in files.entries) {
      archive.addFile(
        ArchiveFile(entry.key, entry.value.length, entry.value),
      );
    }
    final List<int>? encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded ?? const <int>[]);
  }

  /// Liest ein ZIP-Paket; `null`, wenn kein `manifest.json` vorhanden ist.
  PackageContent? readPackage(Uint8List bytes) {
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    ArchiveFile? manifestFile;
    for (final ArchiveFile f in archive.files) {
      if (f.name == 'manifest.json') {
        manifestFile = f;
        break;
      }
    }
    if (manifestFile == null) return null;

    final String jsonText = utf8.decode(_toBytes(manifestFile.content));
    final Map<String, dynamic> json =
        jsonDecode(jsonText) as Map<String, dynamic>;
    final PackageManifest manifest = PackageManifest.fromJson(json);

    final Map<String, Uint8List> files = <String, Uint8List>{};
    for (final ArchiveFile f in archive.files) {
      if (f.isFile && f.name != 'manifest.json') {
        files[f.name] = _toBytes(f.content);
      }
    }

    return PackageContent(manifest: manifest, files: files);
  }

  Uint8List _toBytes(dynamic content) {
    if (content is Uint8List) return content;
    if (content is List<int>) return Uint8List.fromList(content);
    return Uint8List(0);
  }
}
