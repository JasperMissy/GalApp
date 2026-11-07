# Design-System: GaLaBau & Baumpflege App

> **Stand:** 07.11.2026 · **Verbindlich für alle UI-Arbeiten.** Ergänzt `.clinerules` und `docs/Vision.md` (Abschnitt 11).
> **Zielgerät:** zuerst **Android-Handy** (Hochformat). Windows/Linux folgen später, deshalb keine festen Pixelbreiten, sondern flexible Layouts (`Expanded`, `Wrap`, `ConstrainedBox(maxWidth: 640)` für Formulare/Details).

## 1. Leitgedanke

Die Nutzer stehen auf der Baustelle: Handschuhe, Sonnenlicht, wenig Zeit, oft eine Hand frei.
Daraus folgt:

1. **Wenig Text, klare Hierarchie.** Ein Screen hat genau eine Hauptaktion.
2. **Große Touch-Ziele** (mindestens 48×48 dp), Hauptaktion unten gut erreichbar.
3. **Hoher Kontrast** (kein Hellgrau auf Weiß für wichtige Inhalte).
4. **Nichts geht verloren:** Eingaben nie ohne Rückfrage verwerfen, Fehler verständlich auf Deutsch.
5. **Ruhige Optik:** viel Weißraum, weiche Radien, ein Akzent (Grün).

## 2. Tokens

### Farben (nur über `Theme.of(context).colorScheme` bzw. `AppColors`)
| Zweck | Quelle |
|---|---|
| Aktion / Primär | `colorScheme.primary` (GaLaBau-Grün `AppColors.primaryGreen`) |
| Hintergrund | `AppColors.background` (warmes Hellgrau) |
| Karten | `colorScheme.surfaceContainerLowest` mit Border `colorScheme.outlineVariant` |
| Trennlinien | `Colors.grey.shade200` (nie schwarz) |
| Status offen / wiederkehrend / erledigt | `AppColors.statusOpen` (gelb) / `statusRecurring` (blau) / `statusDone` (grün + Haken) |
| Fehler | `colorScheme.error` |

Keine harten Farbwerte (`Colors.red`, `Color(0xFF…)`) in Views. Neue Farben gehören nach `app_colors.dart`.

### Abstände
`4 · 8 · 12 · 16 · 24`. Seitenrand `16`. Abstand zwischen Karten `12`. Innenabstand Karte `16`.
Kein `Card(margin: …)`. Abstände über `ListView(padding: …)` und `SizedBox`.

### Radien
Karten `16`, Buttons/Eingabefelder `12–14`, Chips `999` (Pille), Bilder/Thumbnails `12`.

### Typografie (Inter, über `textTheme`)
| Verwendung | Stil |
|---|---|
| Screen-Titel (AppBar) | `titleLarge`, `w600` |
| Karten-Überschrift | `titleSmall`, `w600` |
| Fließtext | `bodyMedium` |
| Zahlen/Summen | `titleMedium`, `w600` |
| Metazeile | `bodySmall`, `onSurfaceVariant` |

Keine `FontWeight.w700` in Views (nur `w600`). Gewicht möglichst zentral im Theme setzen.

## 3. Komponentenkatalog (`lib/views/shared/`)

| Widget | Datei | Zweck |
|---|---|---|
| `SectionCard` | `section_card.dart` | Karte mit Icon, Überschrift, optionalem `trailing`, Inhalt |
| `StatusChip` | `status_chip.dart` | Pille für Auftragsstatus (offen/wiederkehrend/erledigt) und Rechnungsstatus (Entwurf/Gestellt/Storniert) |
| `EmptyState` | `empty_state.dart` (erweitern) | Icon, Titel, Text, **optional Button** `actionLabel` + `onAction` |
| `LoadingSkeleton` | `loading_skeleton.dart` | Graue Platzhalterkarten (Radius 12) statt nacktem Spinner bei Listen |
| `ErrorState` | `error_state.dart` (besteht) | Fehlertext + „Erneut versuchen“ |
| `Formatters` | `lib/services/formatters.dart` | `date(DateTime)` → `TT.MM.JJJJ`, `euro(int cents)` → `1.234,56 €` (auch negativ), `duration(Duration)` → `2 h 05 min` |
| `QuickActionButton` | `quick_action_button.dart` | Runder Schnellzugriff mit Icon und Label (Anrufen, Navi, Mail) |

Es darf **keine** private `_date()`/`_euro()`-Kopie in Views geben, ausschließlich `Formatters`.

## 4. Screen-Muster

### 4.1 Listen-Screen (Kunden, Aufträge, Kollegen, Rechnungen)
- Suchfeld oben (`SearchBar` oder `TextField` mit Lupe), darunter ggf. Filter-Chips (`FilterChip`, horizontal scrollbar).
- Einträge als `Card` mit `ListTile`: führendes Icon/`CircleAvatar`, Titel, Untertitel (Meta), `trailing` = `StatusChip` oder Betrag.
- `FloatingActionButton.extended` unten rechts für „Neu …“.
- Zustände: Laden → `LoadingSkeleton`, leer → `EmptyState` mit Aktion, Fehler → `ErrorState`.

### 4.2 Detail-Screen Auftrag (3 Reiter)
Kopfbereich (immer sichtbar, über den Reitern, als Karte):
- Titel, `StatusChip`, Kundenname + Adresse
- `QuickActionButton`-Reihe: **Anrufen · Navigieren · Mail**
- Offene Summe/„Noch nicht abgerechnet“ als Info-Zeile

Reiter (Icons + kurze Titel):
1. **Planung** (`event_note_outlined`): Ausführungsdatum, Beschreibung, Notizen, Vorher-Bilder
2. **Ausführung** (`handyman_outlined`): Zeiterfassung, Nachher-Bilder, Materialprotokoll, Anmerkung (Diktat)
3. **Finanzen** (`euro_outlined`): Kalkulation, Rechnungen, Belege (Material/Fremd), Subunternehmer-Rechnungen

AppBar: höchstens **ein** Icon (Teilen) plus `PopupMenuButton` für Bearbeiten, Löschen, Rückmeldung senden, Rechnung senden.
Jeder Reiter hat genau **eine** Hauptaktion (FAB oder `FilledButton`), z. B. Planung → „Bearbeiten“, Ausführung → „Zeit starten/stoppen“, Finanzen → „Rechnung erstellen“.

### 4.3 Formulare
- Kurze Formulare als `showModalBottomSheet(isScrollControlled: true, showDragHandle: true)`, lange als eigener Screen.
- Pflichtfelder markieren, Validierung beim Speichern, Fehlermeldungen unter dem Feld.
- Speichern-Button unten, `FilledButton`, volle Breite. Abbrechen als `TextButton`.
- Zahlenfelder: passender `keyboardType`, Dezimalkomma akzeptieren.

### 4.4 Bestätigungen
- Destruktive Aktionen (Löschen) → `AlertDialog` mit klarem Verb („Löschen“), nicht „OK“.
- **Rechnung stellen** → Dialog mit Text „Nach dem Stellen kann die Rechnung nicht mehr geändert werden. Korrekturen sind nur per Storno möglich.“

### 4.5 Rückmeldung
- Erfolg/Fehler über `SnackBar` (kurz, deutsch, ohne technische Meldungen).
- Lange Vorgänge (PDF, Export, Import) mit sichtbarem Fortschritt und deaktiviertem Button.

## 5. Rechnungsstatus und Unveränderlichkeit (UI-Folgen)

- **Entwurf:** frei editierbar, Chip grau.
- **Gestellt:** Felder nur lesbar, Chip grün. Aktionen: PDF ansehen/teilen, **Stornieren**, **Kopie als neuen Entwurf**. Kein „Bearbeiten“, kein „Löschen“.
- **Storniert** (Stornorechnung existiert): Chip gedämpft rot, Hinweis „Storniert durch ST-2026-0001“.
- **Stornorechnung:** eigene Nummernreihe `ST-JJJJ-NNNN`, negative Beträge, Verweis auf Original.

## 6. Barrierefreiheit und Details

- Jedes Icon-Only-Element hat `tooltip`/`semanticLabel`.
- Schriftskalierung des Systems muss funktionieren (kein festes `height` an Textcontainern).
- Texte nicht abschneiden: `maxLines` + `overflow: TextOverflow.ellipsis` nur bei Metazeilen.
- Datums-/Zeitpicker auf Deutsch (`MaterialApp.locale = Locale('de')`, `localizationsDelegates`).

## 7. Definition of Done (je Screen)

- [ ] Keine harten Farben, kein `Card(margin:)`, kein `Divider(color: Colors.black)`
- [ ] Nur `Formatters` für Datum/Euro/Dauer
- [ ] Laden, Leer und Fehler sind umgesetzt und sehen gut aus
- [ ] Touch-Ziele ≥ 48 dp, Hauptaktion eindeutig
- [ ] Alle Texte deutsch und ohne `TODO`
- [ ] `flutter analyze` ohne Befunde, `flutter test` grün
- [ ] Layout bricht bei großer Schrift und schmaler Breite (320 dp) nicht

