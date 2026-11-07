import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Legt Medien (Fotos, Videos, Sprachmemos) im Auftragsordner ab:
/// `Aufträge/<Titel>/Arbeitsdokumentation/<Unterordner>/<Dateiname>`
/// (Vision, Abschnitt 8).
///
/// Das Basisverzeichnis wird injiziert und ist damit in Tests austauschbar.
class WorkMediaService {
  const WorkMediaService({required this.baseDirectory});

  final Directory baseDirectory;

  /// Schreibt [bytes] als [fileName] in den Unterordner des Auftrags und
  /// gibt den erzeugten Dateipfad zurück.
  Future<String> saveMedia({
    required String orderTitle,
    required String subfolder,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final dir = Directory(
      p.join(
        baseDirectory.path,
        'Aufträge',
        _sanitizeFolder(orderTitle),
        'Arbeitsdokumentation',
        subfolder,
      ),
    );
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Liest alle Medien eines Auftrags (relativer Pfad → Bytes).
  Future<Map<String, Uint8List>> loadMedia(String orderTitle) async {
    final Directory dir = Directory(
      p.join(
        baseDirectory.path,
        'Aufträge',
        _sanitizeFolder(orderTitle),
        'Arbeitsdokumentation',
      ),
    );
    if (!await dir.exists()) return <String, Uint8List>{};
    final Map<String, Uint8List> result = <String, Uint8List>{};
    await for (final FileSystemEntity entity in dir.list(recursive: true)) {
      if (entity is File) {
        final String relPath = p.relative(entity.path, from: dir.path);
        result[relPath] = await entity.readAsBytes();
      }
    }
    return result;
  }

  /// Ersetzt Pfad-Sonderzeichen im Ordnernamen, damit das Speichern auf allen
  /// Plattformen (insb. Windows) zuverlässig funktioniert.
  String _sanitizeFolder(String name) {
    final String cleaned =
        name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.isEmpty
        ? 'auftrag_${DateTime.now().millisecondsSinceEpoch}'
        : cleaned;
  }
}
