/// Rechnungsposition (Datenklasse, 1:1 zum Schema `invoice_items`).
class InvoiceItem {
  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.position,
    required this.description,
    required this.quantityMilli,
    required this.unit,
    required this.unitPriceCents,
    required this.totalCents,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json['id'] as String,
        invoiceId: json['invoice_id'] as String,
        position: json['position'] as int,
        description: json['description'] as String,
        quantityMilli: json['quantity_milli'] as int,
        unit: json['unit'] as String? ?? '',
        unitPriceCents: json['unit_price_cents'] as int,
        totalCents: json['total_cents'] as int,
      );

  final String id;
  final String invoiceId;
  final int position;
  final String description;
  final int quantityMilli;
  final String unit;
  final int unitPriceCents;
  final int totalCents;

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'position': position,
        'description': description,
        'quantity_milli': quantityMilli,
        'unit': unit,
        'unit_price_cents': unitPriceCents,
        'total_cents': totalCents,
      };
}