import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Legt fertige Rechnungs-PDFs im Auftragsordner ab:
/// `Aufträge/<Auftragstitel>/Rechnungen/<Dateiname>` (Vision, Abschnitt 6.4).
///
/// Das Basisverzeichnis (in der App `getApplicationDocumentsDirectory()`)
/// wird injiziert und ist damit in Tests austauschbar.
class InvoiceStorageService {
  const InvoiceStorageService({required this.baseDirectory});

  final Directory baseDirectory;

  /// Schreibt [pdfBytes] als [fileName] in den Rechnungsordner des Auftrags
  /// und gibt den erzeugten Dateipfad zurück.
  ///
  /// Der Auftragstitel wird als Parameter übergeben, da das Order-Model erst
  /// im späteren Kunden-/Auftrags-Schritt entsteht (bewusst entkoppelt).
  Future<String> saveInvoicePdf({
    required String orderTitle,
    required String fileName,
    required Uint8List pdfBytes,
  }) async {
    final dir = Directory(
      p.join(baseDirectory.path, 'Aufträge', orderTitle, 'Rechnungen'),
    );
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(pdfBytes, flush: true);
    return file.path;
  }
}