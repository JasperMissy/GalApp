# Architektur & Implementierungsplan: Rechnungs-Engine (Rechnungswesen & Buchhaltung)

> **Stand:** 05.11.2026
> **Bezug:** `docs/Vision.md` Abschnitte 4.5, 6 und 7.
> **Hinweis zur Quelle:** Dieser Plan setzt die fachlichen Anforderungen eines externen Architektur-Prompts (Invoicing & Bookkeeping Engine) um. Der Prompt beschreibt eine Python-App; hier wird er **1:1 fachlich, aber technisch auf unseren Stack übertragen**: Flutter/Dart, lokal und offline (`.clinerules`). Fachfremde Angaben („Streuobstwiesen“, „Lohfelden“) betreffen unser Projekt nicht und bleiben unberücksichtigt.

## 1. Ziele

1. **Lokale SQLite-Datenbank** für Kunden, Leistungsartikel und Rechnungen.
2. **Automatische, lückenlose Rechnungsnummernvergabe** (`RE-2026-0001`), die der Nutzer im Korrekturschritt überschreiben kann. **Doppelte Nummern sind technisch ausgeschlossen.**
3. **Centgenaue Berechnung** von Netto, MwSt (z. B. 19 %) und Brutto vor dem Speichern.
4. **Konfigurations-basiertes Layout** statt fehleranfälliger `.docx`-Bearbeitung: Stammdaten (Name, Adresse, Steuernummer/USt-IdNr., IBAN) und Design-Optionen (Logo, Primärfarbe) einmalig in den Einstellungen hinterlegt; daraus entsteht ein festes, professionelles PDF.
5. **Fehlerfreie PDF-Ausgabe** in der lokalen Ordnerstruktur.
6. Dieselbe Engine für **Angebote** (eigene laufende Nummer `AN-2026-0001`).

## 2. Technologie-Entscheidungen (Prompt → Flutter/Dart)

| Anforderung aus dem Prompt | Umsetzung in unserem Stack |
|---|---|
| Python, lokal, kein Server | **Flutter/Dart**, lokal, offline (`.clinerules`) |
| SQLite `bookkeeping.db` | **drift** (SQLite-ORM für Dart): typensichere Tabellen, Versionierung und Migrationen. Die Datenbank liegt im lokalen Datenverzeichnis der App. |
| Jinja2 + WeasyPrint (HTML/CSS → PDF) | **`pdf`-Paket (dart:pdf)**: programmatischer PDF-Aufbau, deterministisch, ohne HTML/CSS- oder Word-Fragilität. |
| Logo und Akzentfarbe dynamisch einbinden | Logo als Datei in den Einstellungen (Pfad/Asset), eingebunden per `pw.MemoryImage` mit `BoxFit.contain`; Akzentfarbe als Hex-Wert aus den Einstellungen → `PdfColor.fromHex`. |
| Schrift | eingebundene **Inter**-TTFs (`assets/fonts/`) → `pw.Font.ttf`. |
| Ordner `/Rechnungen/2026/` | Abweichung gemäß Vision 6.4: **Auftragsordner → `Rechnungen/`**, Dateiname `RE-2026-0001.pdf` (das Jahr steckt bereits in der Nummer). Die Rechnungsverwaltung zeigt Verweise. |

## 3. Datenbankschema (SQLite via drift)

Zentrale Tabellen (Beispiel-SQL, drift erzeugt daraus typensichere Klassen und Migrationen):

```sql
-- Kunden (Quelle: Kundenverwaltung der App)
CREATE TABLE clients (
  id         TEXT PRIMARY KEY,             -- UUID
  name       TEXT NOT NULL,
  street     TEXT NOT NULL DEFAULT '',
  zip        TEXT NOT NULL DEFAULT '',
  city       TEXT NOT NULL DEFAULT '',
  phone      TEXT NOT NULL DEFAULT '',
  email      TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL
);

-- Rechnungen und Angebote (eine Tabelle, Typ-Feld)
CREATE TABLE invoices (
  id            TEXT PRIMARY KEY,          -- UUID
  number        TEXT UNIQUE,               -- NULL bei Entwürfen; Eindeutigkeit erzwingt: keine Dubletten
  type          TEXT NOT NULL DEFAULT 'invoice', -- 'invoice' | 'offer'
  client_id     TEXT NOT NULL REFERENCES clients(id),
  order_id      TEXT,                      -- Verweis auf den Auftrag (optional)
  status        TEXT NOT NULL DEFAULT 'draft', -- 'draft' | 'issued' | 'cancelled'
  issued_date   TEXT,                      -- NULL bei Entwurf
  net_cents     INTEGER NOT NULL DEFAULT 0,
  vat_rate_bp   INTEGER NOT NULL DEFAULT 1900, -- Basispunkte: 1900 = 19 %
  vat_cents     INTEGER NOT NULL DEFAULT 0,
  gross_cents   INTEGER NOT NULL DEFAULT 0,
  created_at    TEXT NOT NULL
);

-- Positionen
CREATE TABLE invoice_items (
  id               TEXT PRIMARY KEY,
  invoice_id       TEXT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  position         INTEGER NOT NULL,
  description      TEXT NOT NULL,
  quantity_milli   INTEGER NOT NULL,       -- Menge in Tausendstel (1,5 h = 1500)
  unit             TEXT NOT NULL DEFAULT '',
  unit_price_cents INTEGER NOT NULL,
  total_cents      INTEGER NOT NULL
);

-- Einstellungen (Stammdaten & Rechnungs-Design)
CREATE TABLE settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
-- Wichtige Schlüssel: firmenname, strasse, plz, ort, telefon, email,
-- steuernummer, ust_id, iban, logo_pfad, akzentfarbe, mwst_bp_default,
-- nummern_praefix_rechnung (RE), nummern_praefix_angebot (AN),
-- layout.iban_zeigen, layout.steuernummer_zeigen, layout.fusszeile_text

-- Laufende Nummern je Jahr und Dokumenttyp
CREATE TABLE invoice_sequences (
  year        INTEGER NOT NULL,
  type        TEXT NOT NULL,               -- 'invoice' | 'offer'
  last_number INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (year, type)
);

CREATE INDEX idx_invoices_client ON invoices(client_id);
CREATE INDEX idx_invoices_order  ON invoices(order_id);
```

## 4. Nummernvergabe (automatisch, überschreibbar, eindeutig)

Format: `<Präfix>-<Jahr>-<laufende Nr. 4-stellig>`, z. B. `RE-2026-0001` bzw. `AN-2026-0001`.

Regeln:
- **Entwürfe haben keine Nummer** (Spalte `number` bleibt NULL). Die Nummer wird erst beim „Rechnung stellen“ vergeben. Dadurch entstehen keine Lücken durch verworfene Entwürfe.
- **Vergabe in einer Transaktion:** Sequenz-Zeile anlegen/laden, `last_number + 1`, zurückschreiben und `invoices.number` setzen. Der UNIQUE-Zwang auf `number` fängt jeden Konflikt ab (Rollback + Wiederholung).
- **Überschreiben im Korrekturschritt:** Der Nutzer kann die vorgeschlagene Nummer ändern. Ist sie bereits vergeben, verhindert der UNIQUE-Zwang das Speichern; die App zeigt eine Fehlermeldung und schlägt die nächste freie Nummer vor.
- **Stornierte Rechnungen behalten ihre Nummer** (keine Wiederverwendung – rechtlich sauber).

Pseudocode (Dart):

```dart
String assignNumber(Database db, {required String type, DateTime? date}) {
  final year = (date ?? DateTime.now()).year;
  return db.transaction(() {
    db.insertOrIgnoreSequence(year: year, type: type);
    final seq = db.getSequence(year, type);
    final next = seq.lastNumber + 1;
    db.updateSequence(year, type, next);
    return '${prefixFor(type)}-$year-${next.toString().padLeft(4, '0')}';
  });
}
```

## 5. Rechenlogik (centgenau)

Alles in **Integer-Cent**; MwSt in **Basispunkten** (1900 = 19 %):

- Zeilensumme: `total_cents = roundHalfUp(quantity_milli * unit_price_cents / 1000)`
- Netto: `net = Σ total_cents`
- MwSt: `vat = roundHalfUp(net * vat_rate_bp / 10000)`
- Brutto: `gross = net + vat`
- Berechnung **vor dem Speichern**; gespeicherte Beträge sind damit immer konsistent.

## 6. Layout-System und PDF-Generierung

- **Grund-Layout fest** (unveränderliches, professionelles Gerüst), **individuell über Optionen**: Logo, Akzentfarbe, sichtbare Blöcke (IBAN, Steuernummer, Fußzeilen-Text), optionale Freitext-Felder.
- Aufbau der Seite: Kopf (Logo links, Firmen-Stammdaten rechts) → Akzentlinie in Akzentfarbe → Adressblock (Kunde) → Metadaten (Nummer, Datum) → Positionstabelle (Pos., Bezeichnung, Menge, Einheit, EP, Gesamt) → Summenblock (Netto, MwSt-Satz, Brutto) → Zahlungsinformation (IBAN) → Fußzeile (Steuernummer/USt-IdNr., Freitext).
- Umsetzung mit `dart:pdf` (`pdf`-Paket): Logo per `pw.MemoryImage` + `BoxFit.contain`, Akzentfarbe per `PdfColor.fromHex(settings.akzentfarbe)`, Schrift als eingebettete Inter-TTF.
- **Live-Vorschau** in der App: Die Layout-Optionen werden sofort als Flutter-Vorschau angezeigt. **Geklärt (M3):** Die Vorschau ist ein **Eigenbau-Widget** (Flutter), das das Layout nachbildet; `dart:pdf` erzeugt ausschließlich die PDF-Datei (Export).
- Ablage: Auftragsordner → `Rechnungen/` als `RE-2026-0001.pdf` (Vision 6.4).

## 7. Korrekturschritt

Vor dem Speichern prüft der Nutzer die generierte Rechnung in einer **Vorschau** und kann korrigieren:

- **Vorschau:** Das PDF wird direkt aus dem festen Layout und den eingegebenen Positionen erzeugt und in der App angezeigt.
- **Korrekturen:** Rechnungspositionen, Nummer (überschreibbar, siehe Abschnitt 4), Datum und Layout-Optionen können vor dem Verbuchen geändert werden.
- **Verbuchung:** Erst nach Bestätigung wird die Rechnung als `RE-2026-0001.pdf` im Auftragsordner abgelegt (Vision 6.4) und als Zeile in `Einnahmen.xlsx` übernommen.
- Die **Vorschau-Treue** (Flutter-Vorschau = PDF-Ausgabe) wird in Meilenstein M3 geklärt.

## 8. Modulstruktur (`.clinerules`)

| Modul | Inhalt |
|---|---|
| `lib/models/` | Datenklassen der Rechnungs-Engine (Client, Invoice, InvoiceLine, InvoiceSequence, Setting) inkl. `fromJson` / `toJson` |
| `lib/services/` | SQLite-Zugriff (drift), Nummernvergabe, Rechenlogik (Integer-Cent), PDF-Generator (`dart:pdf`), `.xlsx`-Mapper, ZIP-Export/-Import |
| `lib/views/` | Formular „Rechnung erstellen", Korrekturschritt mit Vorschau, Einstellungen (Stammdaten & Design) |

## 9. Tests

- **Rechenlogik:** Unit-Tests für Zeilensumme, Netto, MwSt und Brutto inkl. Rundung (Integer-Cent).
- **Nummernvergabe:** Tests für Erstvergabe, Folgevergabe, Jahreswechsel und Konfliktbehandlung (UNIQUE).
- **PDF-Smoke-Tests:** Rechnung und Angebot lassen sich mit den Stammdaten erzeugen; Umlaute und Sonderzeichen werden korrekt dargestellt (Inter-TTF).
- **Persistence:** drift-Migrationen laufen auf einer frischen Datenbank fehlerfrei durch.

## 10. Meilensteine M1–M7

| Meilenstein | Inhalt |
|---|---|
| M1 | Vision.md aktualisieren (PDF-Engine statt Vorlagen-Upload) |
| M2 | Architektur-Rechnungswesen.md (dieses Dokument) |
| M3 | PDF-Engine: Layout-System, Vorschau-Rendering, `dart:pdf`-Ausgabe |
| M4 | SQLite-Schema (drift), Stammdaten & Design-Einstellungen |
| M5 | Nummernvergabe (`RE-2026-0001` / `AN-2026-0001`) und Korrekturschritt |
| M6 | Rechnungsverwaltung: Ablage im Auftragsordner, Eintrag in `Einnahmen.xlsx` |
| M7 | Feinschliff: Tests, Fehlerbehandlung, Doku-Abgleich |

**Risiken:**

- **Schriften/Umlaute:** Die eingebettete Inter-TTF muss Umlaute und Sonderzeichen korrekt rendern.
- **Vorschau-Treue:** Flutter-Vorschau und PDF-Ausgabe müssen übereinstimmen.
- **Migrationen:** Schema-Änderungen benötigen drift-Migrationen.
- **Android-Dateirechte:** PDF-Export ist nur in app-eigene Ordner erlaubt.

## 11. Offene Punkte

- **Layout-Umfang:** Welche Blöcke sind fest, welche über die Einstellungen steuerbar?
- **Vorschau-Technik (geklärt):** Eigenbau-Widget (Flutter) für die Vorschau, `dart:pdf` für den Export.
- **Nummern-Konflikt-UX:** Wie wird der Nutzer bei doppelter Nummer informiert?
- **Jahreswechsel:** Sequenz je Jahr (geplant); das Verhalten beim ersten Dokument des neuen Jahres ist zu bestätigen.
- **Rechtliche Korrektheit:** Umgang mit stornierten Rechnungen (Status `cancelled`) und nachträglichen Änderungen.