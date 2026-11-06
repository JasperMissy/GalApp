/// Manifest eines `.galabau`-Pakets (Subunternehmer-Workflow).
class PackageManifest {
  const PackageManifest({
    required this.id,
    required this.type,
    required this.title,
    required this.address,
    required this.description,
    required this.senderName,
    this.invoiceNumber,
    this.issuedDate,
    this.netCents,
    this.grossCents,
  });

  factory PackageManifest.fromJson(Map<String, dynamic> json) =>
      PackageManifest(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'auftrag',
        title: json['title'] as String,
        address: json['address'] as String? ?? '',
        description: json['description'] as String? ?? '',
        senderName: json['sender_name'] as String? ?? '',
        invoiceNumber: json['invoice_number'] as String?,
        issuedDate: json['issued_date'] == null
            ? null
            : DateTime.parse(json['issued_date'] as String),
        netCents: json['net_cents'] as int?,
        grossCents: json['gross_cents'] as int?,
      );

  final String id;
  final String type;
  final String title;
  final String address;
  final String description;
  final String senderName;
  final String? invoiceNumber;
  final DateTime? issuedDate;
  final int? netCents;
  final int? grossCents;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'address': address,
        'description': description,
        'sender_name': senderName,
        'invoice_number': invoiceNumber,
        'issued_date': issuedDate?.toIso8601String(),
        'net_cents': netCents,
        'gross_cents': grossCents,
      };
}
