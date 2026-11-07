# Architektur-Umbau: Daten, GoBD, Bugfixes (Arbeitsplan Architekt)

> **Stand:** 07.11.2026 · Zielplattform zuerst **Android**, danach Windows/Linux (drift_flutter und sqlite3 laufen auf allen drei, daher nur plattformneutrale Pfade über `path_provider`/`path` nutzen).

## Festlegungen

- **Gestellte Rechnungen sind unveränderlich (GoBD).** Entwürfe sind frei editierbar.
- **Storno:** eigene Stornorechnung mit eigener Nummernreihe `ST-JJJJ-NNNN`, negative Beträge, Verweis auf das Original. Das Original bleibt unangetastet. „Storniert“ wird abgeleitet.
- **Korrektur** = Storno + „Kopie als neuer Entwurf“.
- **Schutz auf zwei Ebenen:** Repository lehnt Änderungen ab, SQLite-Trigger (`RAISE(ABORT)`) sichern zusätzlich ab.
- **Änderungsprotokoll** `audit_log` (Ereignis, Objekt-ID, Zeitpunkt, Details).
- Kein neues Paket (`crypto` nur nach Freigabe, für PDF-Hash).
- `.xlsx`/DATEV/EÜR werden aus der Datenbank **neu erzeugt**, nicht angehängt.

## Reihenfolge

| # | Paket | Befund |
|---|---|---|
| A1 | `PRAGMA foreign_keys = ON` in `beforeOpen`, Migration v8: Waisen bereinigen, FKs mit Cascade für `work_time_entries`, `work_notes`, `order_packages`; fehlenden Index `idx_orders_client` nachziehen; Migrationstest v1→v8 | 3, 9 |
| A2 | Tabelle `expenses` (Material/Fremd/Personal, optional Auftrag/Kollege, Beleg-Pfad); „Assoziierte Rechnung“ schreibt dorthin statt in `invoices`; Altbestand migrieren | 1 |
| A3 | Tabelle `work_segments` (travel/work/pause), Zeitberechnung inkl. Pausen, Verbot paralleler offener Segmente; Altbestand aus `work_time_entries` migrieren | 2, 7 |
| A4 | Rechnungsstatus `draft/issued`, Stornorechnung (`storno_of`, Reihe `ST`), Trigger auf `invoices` und `invoice_items`, Repository-Guards, `audit_log` | GoBD |
| A5 | Atomarer Rechnungsfluss: erst PDF erzeugen und schreiben (temporäre Datei), dann DB-Transaktion mit Nummernvergabe, dann Umbenennen; bei Fehler Rollback und Aufräumen | 4 |
| A6 | `ordersProvider` & Co. als `StreamProvider`, Fehlerbehandlung (UNIQUE-Konflikt, Dateifehler) mit verständlichen Meldungen | 6, 8 |
| A7 | Medienpfade nach `orderId` statt Titel (mit Umzug vorhandener Ordner) | 5 |
| A8 | `Order.copyWith`, `updateDueDate`; Datumskonverter mit UTC-Speicherung | 10, 11 |
| A9 | Buchungszeilen-Tabelle, Kleinunternehmer-Schalter, Export aus DB | Vision 6.6 |
| A10 | Backup-Export (DB + Medien als ZIP) und Wiederherstellung | Local-First |

Nach jedem Paket: `flutter analyze`, `flutter test`, neue Tests für die jeweilige Logik.

## Koordination mit dem UI-Modell

Das UI-Modell arbeitet laut `docs/Umsetzung-DeepSeek.md` nicht in `lib/services/database/`, `lib/services/invoicing/` oder `lib/models/`. Änderungen an Provider-Signaturen (A6) werden erst gemacht, wenn UI-Paket 4 abgeschlossen ist, damit keine Merge-Konflikte entstehen.
