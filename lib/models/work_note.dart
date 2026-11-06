/// Anmerkung zur Arbeitsdokumentation eines Auftrags.
class WorkNote {
  const WorkNote({
    required this.orderId,
    required this.text,
    required this.updatedAt,
  });

  factory WorkNote.fromJson(Map<String, dynamic> json) => WorkNote(
        orderId: json['order_id'] as String,
        text: json['text'] as String? ?? '',
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  final String orderId;
  final String text;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'text': text,
        'updated_at': updatedAt.toIso8601String(),
      };
}
