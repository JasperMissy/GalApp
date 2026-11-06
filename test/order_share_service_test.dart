import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/packages/order_share_service.dart';

void main() {
  test('buildShareManifest baut das Auftrags-Paket', () {
    final Client client = Client(
      id: 'k-1',
      name: 'Max Mustermann',
      street: 'Beispielweg 1',
      zip: '34123',
      city: 'Kassel',
      phone: '',
      email: '',
      createdAt: DateTime(2026),
    );
    final Order order = Order(
      id: 'a-1',
      clientId: 'k-1',
      title: 'Laubentfernung',
      description: 'Vorgarten',
      createdAt: DateTime(2026),
      dueDateStart: null,
      dueDateEnd: null,
      status: OrderStatus.offen,
      recurring: false,
      notes: '',
    );

    final manifest = buildShareManifest(
      packageId: 'pkg-1',
      order: order,
      client: client,
      senderName: 'Chef GmbH',
    );

    expect(manifest.id, 'pkg-1');
    expect(manifest.type, 'auftrag');
    expect(manifest.title, 'Laubentfernung');
    expect(manifest.address, 'Beispielweg 1, 34123 Kassel');
    expect(manifest.description, 'Vorgarten');
    expect(manifest.senderName, 'Chef GmbH');
  });
}
