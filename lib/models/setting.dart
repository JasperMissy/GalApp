/// Einstellung (Stammdaten & Rechnungs-Design),
/// Datenklasse 1:1 zum Schema `settings`.
class Setting {
  const Setting({required this.key, required this.value});

  factory Setting.fromJson(Map<String, dynamic> json) => Setting(
        key: json['key'] as String,
        value: json['value'] as String,
      );

  final String key;
  final String value;

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}