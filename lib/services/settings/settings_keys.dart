/// Schlüssel der `settings`-Tabelle
/// (docs/Architektur-Rechnungswesen.md, Abschnitt 3).
abstract final class SettingsKeys {
  static const String firmenname = 'firmenname';
  static const String strasse = 'strasse';
  static const String plz = 'plz';
  static const String ort = 'ort';
  static const String telefon = 'telefon';
  static const String email = 'email';
  static const String steuernummer = 'steuernummer';
  static const String ustId = 'ust_id';
  static const String iban = 'iban';
  static const String akzentfarbe = 'akzentfarbe';

  /// Kleinunternehmerregelung (§19 UStG): Wert 'ja' oder 'nein'.
  static const String kleinunternehmer = 'kleinunternehmer';
}