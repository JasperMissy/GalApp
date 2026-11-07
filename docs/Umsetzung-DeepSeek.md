# Arbeitsanweisung für das UI-Umsetzungsmodell (DeepSeek)

> **Lies zuerst:** `.clinerules`, `docs/Design-System.md`, `docs/Vision.md`. Dieses Dokument gibt dir die **Reihenfolge der Arbeitspakete**. Die gestalterischen Vorgaben stehen im Design-System und gelten verbindlich.

## Globale Regeln

1. **Nur Pakete aus `pubspec.yaml` benutzen.** Keine neuen Abhängigkeiten.
2. **Nicht anfassen:** `lib/services/database/` (inkl. `*.g.dart`), `lib/services/invoicing/`, `lib/services/packages/`, `lib/models/`. Diese Bereiche werden vom Architekten umgebaut. Fehlt dir dort etwas, schreib es unten in „Offene Fragen“ statt es selbst zu ändern.
3. **Keine neuen Features.** Nur Optik, Struktur und Bedienbarkeit. Verhalten bleibt gleich.
4. **Kein Cloud-Dienst, keine Netzwerkaufrufe** hinzufügen.
5. **Ein Paket nach dem anderen.** Nach **jedem** Paket: `flutter analyze` (muss ohne Befund sein) und `flutter test` (muss grün sein). Erst dann das nächste Paket.
6. Kommentare und UI-Texte auf **Deutsch**. Keine `TODO`s.
7. Dateien klein halten: Wird ein Screen > 300 Zeilen, Teile als eigene Widgets in eine eigene Datei auslagern.
8. Wenn du unsicher bist, nimm die einfachere Lösung, die dem Design-System entspricht.

## Paket 1: Theme

**Datei:** `lib/views/theme/app_theme.dart`, ggf. `app_colors.dart`

- `appBarTheme`: Hintergrund `scheme.surface`, Vordergrund `scheme.onSurface`, `elevation: 0`, `scrolledUnderElevation: 0`, `surfaceTintColor: Colors.transparent`, Titel `w600`.
- `tabBarTheme`: Label `scheme.primary`, nicht ausgewählt `scheme.onSurfaceVariant`, Indikator `scheme.primary`, `dividerColor` dezent (`Colors.grey.shade200`).
- `cardTheme`: `elevation: 0`, `margin: EdgeInsets.zero`, Radius 16, Border `scheme.outlineVariant`, Farbe `scheme.surfaceContainerLowest`.
- `dividerTheme`: `Colors.grey.shade200`, `space: 1`.
- `inputDecorationTheme`: Border `scheme.outlineVariant`, fokussiert `scheme.primary` (Breite 2), Radius 12.
- `chipTheme`: Pillenform, ohne harten Rand.
- `navigationBarTheme`: Hintergrund `scheme.surface`, Indikator Primär mit Alpha 0.16.
- Kein `Colors.white` mehr fest einbauen; stattdessen Rollen aus `scheme`.
- `ColorScheme.fromSeed(...)`: Die `copyWith(primary: …)`-Überschreibung beibehalten, aber zusätzlich `primaryContainer` und `onPrimaryContainer` passend setzen, damit Container-Farben harmonieren.

**Akzeptanz:** App startet, alle Screens sehen konsistent aus, keine grüne AppBar mehr.

## Paket 2: Shared Widgets und Formatter

**Neue Dateien:** `lib/views/shared/section_card.dart`, `status_chip.dart`, `loading_skeleton.dart`, `quick_action_button.dart`, `lib/services/formatters.dart`
**Anpassen:** `lib/views/shared/empty_state.dart` (optional `actionLabel` + `onAction`, rückwärtskompatibel).

- Signaturen und Verhalten wie im Design-System (Abschnitt 3).
- `Formatters.euro(int cents)`: Tausenderpunkt, Dezimalkomma, Suffix ` €`, negative Beträge korrekt (`-0,05 €`, `-1.234,56 €`).
- `Formatters.date(DateTime)`: `TT.MM.JJJJ`. `Formatters.duration(Duration)`: `2 h 05 min`, unter einer Stunde `45 min`.
- **Unit-Tests** in `test/formatters_test.dart` für Euro (0, 5, 100, 123456, −5, −123456), Datum, Dauer.

**Akzeptanz:** Tests grün, Widgets sind mit `const` konstruierbar wo möglich.

## Paket 3: Formatter überall einsetzen

- Alle privaten `_date`, `_euro`, `_time`-Helfer in `lib/views/**` durch `Formatters` ersetzen. Suche: `String _date(`, `String _euro(`, `String _time(`, `padLeft(2, '0')`.
- Der Ausgabewert von `Formatters.euro` enthält schon das `€`, entferne manuell angehängte `' €'`.

**Akzeptanz:** Keine Duplikate mehr, UI zeigt `1.234,56 €`.

## Paket 4: Auftragsdetail (Referenz-Screen)

**Dateien:** `lib/views/customers/order_detail_screen.dart`, `order_overview_tab.dart`, `work_documentation_tab.dart`. Neue Dateien nach Bedarf, z. B. `order_header_card.dart`, `order_finance_tab.dart`.

- Aufbau exakt nach Design-System 4.2: Kopfkarte (Titel, `StatusChip`, Kunde, Schnellaktionen Anrufen/Navigieren/Mail via `url_launcher`: `tel:`, Karten-URL, `mailto:`), darunter 3 Reiter **Planung · Ausführung · Finanzen**.
- Aus „Übersicht“ wird **Planung**, aus „Dokumentation“ wird **Ausführung**, aus „Rechnungen“ wird **Finanzen**. Inhalte jeweils in `SectionCard`s statt `Divider`.
- AppBar: nur Teilen-Icon + `PopupMenuButton` (Bearbeiten, Löschen, bei `origin == 'erhalten'` zusätzlich Rückmeldung senden und Rechnung senden).
- Bestehende Logik (`_share`, `_edit`, `_delete`, `_sendFeedback`, `_sendInvoice`, `_generate`, `_addAssociated`) **unverändert übernehmen**, nur die Oberfläche ändern.
- Ausführung: Zeitliste als Karten mit Dauer (`Formatters.duration`); der laufende Timer groß (`headlineMedium`), darunter ein großer Start/Pause/Stopp-Button.
- Medien: Thumbnails (Radius 12) im `Wrap`, Buttons Foto/Galerie/Video/Sprachmemo in einer `SectionCard`.
- Leere Bereiche → `EmptyState` mit Aktion (z. B. „Erste Zeit erfassen“).

**Akzeptanz:** Alle bisherigen Aktionen funktionieren weiterhin. Der Screen erfüllt die Definition of Done des Design-Systems.

## Paket 5: Home / Dashboard

**Datei:** `lib/views/home/home_view.dart` (+ neue Widgets in `lib/views/home/`)

- Begrüßung `Hallo, <Name>!` (Name aus `settingsRepositoryProvider`, Schlüssel aus `SettingsKeys`; fehlt er, nur `Hallo!`).
- Karte **Heute**: Aufträge aus `ordersProvider` mit `dueDateStart` heute und Status offen, je Zeile `StatusChip`, Kundenname, Tipp öffnet den Auftrag.
- Kachel **Offene Aufträge** (Anzahl). Weitere Kennzahlen nur, wenn sie mit vorhandenen Providern ermittelbar sind.
- Wetter-Karte als Platzhalter lassen (kein Netzwerk).
- Leerer Zustand: `EmptyState` „Heute ist nichts geplant“ mit Aktion „Auftrag anlegen“.

**Akzeptanz:** Kein neuer Netzwerkzugriff, Layout bricht bei 320 dp nicht.

## Paket 6: Listen-Screens

**Dateien:** `customers_view.dart`, `colleagues_view.dart`, `calendar_view.dart`, `extras_view.dart`, `invoice_management_view.dart`, `client_invoices_screen.dart`, `colleague_invoices_screen.dart`

- Muster Design-System 4.1: Suchfeld, Filter-Chips, Karten mit `ListTile`, `FloatingActionButton.extended`.
- Lade-, Leer- und Fehlerzustände einheitlich.
- Rechnungslisten: `StatusChip`, Betrag mit `Formatters.euro`.

## Paket 7: Formulare und Dialoge

**Dateien:** `client_form_dialog.dart`, `order_form_dialog.dart`, `invoice_form_dialog.dart`, `colleague_form_dialog.dart`, `associated_invoice_dialog.dart`, `calculation_screen.dart`, `settings_screen.dart`

- Kurze Formulare als Bottom-Sheet bzw. Vollbild-Dialog, Speichern-Button unten, Validierung nach Design-System 4.3.
- Rechnungsformular: Vor dem Stellen der Hinweisdialog nach Design-System 4.4.
- **Keine Logik ändern**, Rückgabewerte der Dialoge (`Navigator.pop(...)`) bleiben gleich.

## Paket 8: Abschluss

- Gesamt-Durchgang gegen die Checkliste „Definition of Done“.
- Suche nach Verstößen: `Colors.white`, `Colors.black`, `Colors.red`, `margin:`, `FontWeight.w700`, `Divider(`, `TODO`.
- `flutter analyze` und `flutter test`, danach die Liste der geänderten Dateien hier eintragen.

## Offene Fragen (vom Umsetzer zu füllen)

_(leer)_

