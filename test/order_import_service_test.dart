import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/models/package_manifest.dart';
import 'package:galabau_app/services/packages/order_import_service.dart';

void main() {
  test('buildImportedOrder baut einen externen Auftrag', () {
    final PackageManifest manifest = PackageManifest(
      id: 'pkg-1',
      type: 'auftrag',
      title: 'Baumschnitt',
      address: 'Musterweg 1, 34123 Kassel',
      description: 'Krone einkürzen',
      senderName: 'Chef GmbH',
    );

    final order = buildImportedOrder(orderId: 'a-1', manifest: manifest);

    expect(order.id, 'a-1');
    expect(order.clientId, isNull);
    expect(order.title, 'Baumschnitt');
    expect(order.origin, 'erhalten');
    expect(order.packageId, 'pkg-1');
    expect(order.externalAddress, 'Musterweg 1, 34123 Kassel');
    expect(order.senderName, 'Chef GmbH');
    expect(order.status, OrderStatus.offen);
  });

  test('buildImportedPackage baut den eingehenden Eintrag', () {
    final pkg = buildImportedPackage(packageId: 'pkg-1', orderId: 'a-1');

    expect(pkg.id, 'pkg-1');
    expect(pkg.orderId, 'a-1');
    expect(pkg.colleagueId, isNull);
    expect(pkg.direction, 'incoming');
    expect(pkg.status, 'received');
  });
}
