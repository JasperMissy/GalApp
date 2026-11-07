import 'dart:convert';
import 'dart:typed_data';

import '../../models/package_manifest.dart';
import '../../models/work_time_entry.dart';

/// Daten einer zurückzusendenden Rechnung.
class InvoiceFeedbackData {
  const InvoiceFeedbackData({
    required this.number,
    required this.netCents,
    required this.grossCents,
    this.pdfBytes,
  });

  final String number;
  final int netCents;
  final int grossCents;
  final Uint8List? pdfBytes;
}

/// Baut das Manifest für eine zurückzusendende Rechnung.
PackageManifest buildInvoiceManifest({
  required String packageId,
  required InvoiceFeedbackData data,
  required String senderName,
}) {
  return PackageManifest(
    id: packageId,
    type: 'rechnung',
    title: data.number,
    address: '',
    description: '',
    senderName: senderName,
    invoiceNumber: data.number,
    issuedDate: DateTime.now(),
    netCents: data.netCents,
    grossCents: data.grossCents,
  );
}

/// Baut das Manifest für eine Rückmeldung (Subunternehmer → Auftraggeber).
PackageManifest buildFeedbackManifest({
  required String packageId,
  required String title,
  required String senderName,
}) {
  return PackageManifest(
    id: packageId,
    type: 'rückmeldung',
    title: title,
    address: '',
    description: '',
    senderName: senderName,
  );
}

/// Serialisiert Zeiterfassung + Anmerkung als JSON
/// (Datei `arbeitsdokumentation.json` im Rück-Paket).
String buildWorkDocumentationJson({
  required List<WorkTimeEntry> times,
  required String note,
}) {
  return jsonEncode(<String, dynamic>{
    'times': <Map<String, dynamic>>[
      for (final WorkTimeEntry t in times)
        <String, dynamic>{
          'started_at': t.startedAt.toIso8601String(),
          'ended_at': t.endedAt?.toIso8601String(),
          'paused_at': t.pausedAt?.toIso8601String(),
        },
    ],
    'note': note,
  });
}
