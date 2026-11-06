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
        orderTitle,
        'Arbeitsdokumentation',
        subfolder,
      ),
    );
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
