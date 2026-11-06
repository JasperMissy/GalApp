import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/work_time_entry.dart';
import 'package:galabau_app/services/packages/order_feedback_service.dart';

void main() {
  test('buildFeedbackManifest baut ein Rückmeldungs-Manifest', () {
    final manifest = buildFeedbackManifest(
      packageId: 'pkg-1',
      title: 'Baumschnitt',
      senderName: 'Sub GmbH',
    );

    expect(manifest.id, 'pkg-1');
    expect(manifest.type, 'rückmeldung');
    expect(manifest.title, 'Baumschnitt');
    expect(manifest.senderName, 'Sub GmbH');
  });

  test('buildWorkDocumentationJson serialisiert Zeiten und Anmerkung', () {
    final List<WorkTimeEntry> times = <WorkTimeEntry>[
      WorkTimeEntry(
        id: 't-1',
        orderId: 'a-1',
        startedAt: DateTime(2026, 11, 5, 8),
        endedAt: DateTime(2026, 11, 5, 12),
        createdAt: DateTime(2026, 11, 5, 8),
      ),
    ];

    final String json = buildWorkDocumentationJson(
      times: times,
      note: 'Alles erledigt',
    );

    expect(json, contains('"note":"Alles erledigt"'));
    expect(json, contains('2026-11-05T08:00:00'));
    expect(json, contains('"ended_at"'));
  });

  test('buildInvoiceManifest baut ein Rechnungs-Manifest', () {
    final InvoiceFeedbackData data = InvoiceFeedbackData(
      number: 'RE-2026-0001',
      netCents: 10000,
      grossCents: 11900,
    );

    final manifest = buildInvoiceManifest(
      packageId: 'pkg-1',
      data: data,
      senderName: 'Sub GmbH',
    );

    expect(manifest.id, 'pkg-1');
    expect(manifest.type, 'rechnung');
    expect(manifest.invoiceNumber, 'RE-2026-0001');
    expect(manifest.netCents, 10000);
    expect(manifest.grossCents, 11900);
    expect(manifest.senderName, 'Sub GmbH');
  });
}
