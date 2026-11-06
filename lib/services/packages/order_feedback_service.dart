import 'dart:convert';

import '../../models/package_manifest.dart';
import '../../models/work_time_entry.dart';

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
        },
    ],
    'note': note,
  });
}
