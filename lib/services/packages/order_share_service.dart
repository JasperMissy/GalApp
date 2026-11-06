import '../../models/client.dart';
import '../../models/order.dart';
import '../../models/package_manifest.dart';

/// Baut das Manifest für das Teilen eines eigenen Auftrags.
PackageManifest buildShareManifest({
  required String packageId,
  required Order order,
  required Client client,
  required String senderName,
}) {
  return PackageManifest(
    id: packageId,
    type: 'auftrag',
    title: order.title,
    address: '${client.street}, ${client.zip} ${client.city}',
    description: order.description,
    senderName: senderName,
  );
}
