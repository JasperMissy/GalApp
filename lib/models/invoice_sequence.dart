/// Laufende Nummer je Jahr und Dokumenttyp
/// (Datenklasse, 1:1 zum Schema `invoice_sequences`).
class InvoiceSequence {
  const InvoiceSequence({
    required this.year,
    required this.type,
    required this.lastNumber,
  });

  factory InvoiceSequence.fromJson(Map<String, dynamic> json) =>
      InvoiceSequence(
        year: json['year'] as int,
        type: json['type'] as String,
        lastNumber: json['last_number'] as int? ?? 0,
      );

  final int year;
  final String type;
  final int lastNumber;

  Map<String, dynamic> toJson() => {
        'year': year,
        'type': type,
        'last_number': lastNumber,
      };
}