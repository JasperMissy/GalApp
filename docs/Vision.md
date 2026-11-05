# Vision: GaLaBau & Baumpflege App

> **Stand:** 05.11.2026
> **Quellen:** `docs/Vektorflow.svg` / `docs/App-Skizze-1.png` (Excalidraw-Skizze 1) sowie die mündlichen Erläuterungen des Auftraggebers.
> **Status:** Lebendes Dokument – wird mit jeder weiteren Skizze/Anweisung fortgeschrieben.
> **Verbindliche Entwicklungsregeln:** siehe `.clinerules` im Projektstamm.

---

## 1. Überblick & Grundprinzipien

Die App richtet sich an **Einzelunternehmer in der Baumpflege und im Garten- und Landschaftsbau (GaLaBau)**.

| Prinzip | Bedeutung |
|---|---|
| **Open Source** | Der Quellcode ist offen und nachvollziehbar. |
| **Datenschutzfreundlich** | Keine Cloud-Dienste und keine Server-Datenspeicherung für Kundendaten. |
| **Strikt lokale Datenhaltung** | Alle Daten (Kunden, Aufträge, Zeiten, Rechnungen) liegen ausschließlich auf dem Gerät des Nutzers. |
| **Austausch über Datenpakete** | Der Datenaustausch zwischen Geräten (z. B. mit Subunternehmern) erfolgt ausschließlich über lokale ZIP-Datenpakete (`.galabau` / `.zip`), die der Nutzer selbst per Messenger (z. B. Signal) verschickt. Es gibt keinen Server dazwischen. |
| **Intuitive Datenstruktur** | Die Struktur in der App und die Ordnerstruktur auf dem Gerät sind einfach und gleich aufgebaut. Der Nutzer findet seine Daten auch ohne die App wieder. |
| **Präzision** | Keine ungefragten Features und keine Cloud-Abhängigkeiten. |

### Technische Leitplanken (aus `.clinerules`)

- Framework: **Flutter / Dart**
- Modulstruktur:
  - `lib/models/` – nur Datenklassen inkl. `fromJson` / `toJson`
  - `lib/views/` – UI-Screens & Widgets
  - `lib/services/` – lokaler Speicher, ZIP-Export/-Import, `.docx`-Mapper
- State Management: **Provider oder Riverpod**
- Lokale Speicherung: z. B. Hive oder SQLite
- Sauberer, modularisierter Dart-Code ohne ungelöste `todos`

---

## 2. Funktionsumfang (Kurzüberblick)

1. Kunden- und Auftragsverwaltung
2. Kalkulation, Rechnungs- und Angebotserstellung nach **individueller `.docx`-Vorlage**
3. Rechnungsverwaltung und Buchhaltung (Einnahmen, Ausgaben, MwSt.) mit drei `.xlsx`-Tabellendokumenten (Einnahmen, Materialkosten, Personalkosten); Rechnungsimport per PDF und Erfassung von Betriebsausgaben per Beleg-Foto (Kamera)
4. Auftragsvergabe an Subunternehmer („Auftrag teilen") mit Zeiterfassung, „Nachher-Bildern" und Anmerkungen
5. Kollegen-Datenbank inkl. Qualifikationen
6. Einfacher Kalender
7. Startseite mit Begrüßung, Wetter und Tagesaufgaben

---

## 3. Navigation & Module

Die untere Navigationsleiste hat laut Skizze **5 Einträge** (von links nach rechts):

`Kunden` · `Kalender` · `Home` · `Kollegen` · `Extras`

„Aufträge" ist **kein eigener Menüpunkt**, sondern ein Bereich innerhalb von **Kunden** (Ansicht „Kunden / Aufträge").

### 3.1 Home (Startseite / HOMESCREEN)

- Variabler Begrüßungstext, z. B. „Hallo, `<username>`!"
- Wetter-Widget: Standort + Temperatur in °C, passendes Wettersymbol (Sonne, leicht bewölkt, Regen, Schnee …)
- **Tasks Today / Todos** → führt zum Kalender bzw. zu den offenen Aufträgen

### 3.2 Kunden (mit Unterbereich Aufträge)

**Ansicht „Kunden":**
- Karte: Open-Street-Map mit Kundenverzeichnis
- Suchfunktion
- Kundenliste, alphabetisch geordnet (Name + PLZ untergeordnet)
- **Kunde hinzufügen:** Name, Adresse, Telefon, E-Mail
- Kundendetails (Beispiel: Max Mustermann, 34153) mit drei Schnellaktionen:
  - **Anrufen (Call):** Die Telefon-App öffnet sich mit der Nummer des Kunden.
  - **Navi:** Eine Navigations-App öffnet sich (z. B. OsmAnd, Google Maps) mit der Adresse des Kunden.
  - **Mail:** Das zugeordnete Mailprogramm des Handys öffnet sich mit einer neuen Mail an den Kunden.
- Kundenordner mit dem Zugang zu den Aufträgen des Kunden
- **Rechnungsordner** (Button in den Kundendetails): zeigt **alle Rechnungen, die an diesen Kunden gestellt wurden**. Die Dateien liegen nur einmal vor und werden hier als Querverweis angezeigt (siehe Abschnitt 3.6).

**Ansicht „Aufträge":**
- Auftragsliste, chronologisch, mit `<Titel>` · `<Kundenname>` · `<PLZ>`
- Filterfunktion: **Offen / Erledigt / wiederkehrend**
- Beispieleintrag: „29.11.27 Laubentfernung – Max Mustermann – 34123 – Erledigt"
- Auswahl eines Eintrags öffnet den Auftragsordner
- **Neuer Auftrag** (siehe Abschnitt 4.2)

### 3.3 Kalender

- Einfache Kalenderfunktion
- Zeigt offene Aufträge und deren Ausführungstermine (Datum + optional Uhrzeit [Anfang, Ende])
- Ausführungsdaten aus Aufträgen werden mit dem Kalender synchronisiert
- Wiederkehrende Aufträge sind möglich und werden extra markiert (z. B. blau)

### 3.4 Kollegen

- Alphabetische Kontaktliste
- Kontaktdetails
- Weitere Details zu **Qualifikationen**, z. B. SKT-A, SKT-B, Hängerführerschein
- **Rechnungen** der jeweiligen Person (z. B. eines Subunternehmers): zeigt die ihr zugeordneten, importierten Rechnungen als Querverweis (siehe Abschnitt 3.6). Hier kann auch direkt eine **Rechnung importiert** werden, die Person ist dann bereits zugeordnet (siehe Abschnitt 6.5).

### 3.5 Extras

| Funktion | Beschreibung |
|---|---|
| **Rechnungsverwaltung** | Ordner mit den Unterordnern **Einnahmen** und **Ausgaben** (Ausgaben unterteilt in **Materialkosten** und **Personalkosten**), siehe Abschnitt 6 |
| **Rechnungsvorlage** | Upload der individuellen Rechnungsvorlage als `.docx` + Festlegung der Platzhalter (siehe Abschnitt 7) |
| **Angebotsvorlage** | Dieselbe Funktion für Angebote |

### 3.6 Querverweise (Übersicht für den Nutzer)

Dieselben Dateien, insbesondere Rechnungen, tauchen an **mehreren Stellen der App** auf. Sie sind als **Querverweise** angelegt: Die Datei liegt nur **einmal** im Dateisystem, wird aber an jeder passenden Stelle angezeigt. Das schafft Übersicht für den Nutzer, ohne Daten zu duplizieren.

| Ansicht | Zeigt |
|---|---|
| Kunden → Kundendetails → **Rechnungsordner** | alle Rechnungen, die an diesen Kunden gestellt wurden |
| Kunden → Auftrag → **Rechnungen** | die Rechnungen dieses Auftrags, auch die importierten Subunternehmer-Rechnungen |
| Kollegen → Person → **Rechnungen** | die Rechnungen dieses Subunternehmers, der jeweiligen Person zugeordnet |
| Extras → Rechnungsverwaltung → **Einnahmen** | alle gestellten Rechnungen, chronologisch |
| Extras → Rechnungsverwaltung → Ausgaben → **Materialkosten** | alle importierten Materialrechnungen, chronologisch |
| Extras → Rechnungsverwaltung → Ausgaben → **Personalkosten** | alle importierten Subunternehmer-Rechnungen, chronologisch |

> **Entschieden:** Es wird mit **Verweisen** gearbeitet, nicht mit Dateikopien. Wo die Datei physisch liegt, steht in Abschnitt 6.4. Die technische Umsetzung ist noch offen (siehe Abschnitt 9).

---

## 4. Haupt-Workflow

**Home → Kundendatenbank → Auftrag erstellen → Auftragsordner**

### 4.1 Kunde wählen oder anlegen
Über Kunden → Kundenliste oder Karte; neue Kunden werden mit Name, Adresse, Telefon und E-Mail angelegt. Dabei entsteht der **Kundenordner**.

### 4.2 Auftrag erstellen („neuer Auftrag")

| Feld | Beschreibung |
|---|---|
| Titel | Textfeld |
| Auftragsbeschreibung | „Was muss gemacht werden?" – inkl. **Diktierfunktion** |
| Medien | Fotos, Videos, Sprachmemos oder PDF hinzufügen |
| Notizen / Anmerkungen | Freitext |
| Aktionen | **Speichern** oder **Abbrechen** (zurück) |

Beim Speichern wird der **Auftragsordner automatisch erstellt**.

### 4.3 Auftragsordner / Auftragsdetails

- Auftragstitel, Erfassungsdatum, Kundenname, Adresse
- Funktion: **bearbeiten / löschen**
- **Status:** Offen / Erledigt
  - Offene Aufträge werden gelb markiert.
  - Bei „Erledigt" wird das Ausführungsdatum festgeschrieben, und das Kalkulationstool verschwindet.
  - Wiederkehrende Aufträge werden extra markiert (z. B. blau).
- **Ausführungsdatum festlegen:** Datum + optional Uhrzeit [Anfang, Ende]; Synchronisation mit dem Kalender; wiederkehrend möglich
- **Auftrag teilen** (Übergabe an Subunternehmer, siehe Abschnitt 5)
- **Unterordner des Auftrags:**
  1. **Auftragsdetails** – Auftragsbeschreibung inkl. Dateien, Notizen, Anmerkungen
  2. **Arbeitsdokumentation** – Nachher-Bilder, Zeiterfassung, Anmerkungen
  3. **Assoziierte Rechnungen** – z. B. Materialkosten, Subunternehmer-Rechnungen; `.pdf`-Dateien können importiert werden
  4. **Rechnungen** – Kalkulation, erstellte Rechnungen, Subunternehmerrechnungen

### 4.4 Kalkulationsrechner („Kostenkalkulation `<Auftragstitel>`")

- Kopf: Kundenname, Adresse, Erfassungsdatum
- Rechnungsparameter, z. B. **Pos. / Bezeichnung / Menge / Summe**
- Beispielzeile: `1 – Laubentfernung – 18 – 65 €/h – 360 €`
- **Position hinzufügen:** Es öffnet sich ein Formular zur Abfrage der Rechnungsparameter.
- **Summe + ggf. MwSt., TOTAL**
- Aktionen: **Speichern**, **Abbrechen**, **Exportieren**
- Option: **Angebot erstellen** nach der individuellen, hochgeladenen Vorlage als `.docx` oder `.pdf`, oder alternativ ein PDF direkt generieren

### 4.5 Rechnung generieren

- Aus dem Auftrag heraus über „Rechnung generieren"
- Layout **gemäß individueller Rechnungsvorlage** (Briefkopf, Adressat: Kunde, Rechnungsnr., Datum, Rechnungspositionen, Summe + ggf. MwSt., TOTAL)
- Es öffnet sich ein **Formular zur Eingabe der Rechnungspositionen**. Als Blueprint dient die hochgeladene `.docx`-Rechnungsvorlage mit den individuellen Rechnungsparametern.
- Ausgabe **gemäß Rechnungsvorlage als `.pdf` oder `.docx`**
- Die **Rechnungsnummer** gibt der Nutzer **selbst im Formular „Rechnung erstellen"** im Auftragsordner ein. Es gibt keine automatische Nummernvergabe. Die Registrierung der Rechnung findet nur bei **eigenen Aufträgen** statt.
- Gespeichert wird unter `<Rechnungen Auftragstitel>` als bearbeitbares Formular.
- Nach **Bestätigung durch den Nutzer** wird die Rechnung in der Rechnungsverwaltung abgelegt (siehe Abschnitt 6).

---

## 5. Subunternehmer-Workflow

> Der Auftraggeber hält ein weiteres Flowdiagramm für nicht nötig. Dieser Abschnitt ist die Referenz für den Subunternehmer-Workflow.

„Auftrag teilen" meint die **Übergabe eines Auftrags an einen Subunternehmer**.

1. Der Auftragsersteller wählt im Auftrag **„Auftrag teilen"** und den **Kontakt** (Subunternehmer) aus der Kollegen-Datenbank. Daraus entsteht ein lokales **`.galabau`-Datenpaket** (ZIP) mit folgendem Inhalt:
   - **Auftragstitel**
   - **Adresse**
   - **Auftragsbeschreibung** inkl. eventueller Bilder, Videos, Sprachmemos und Anmerkungen
   - eine interne **Paket-ID**. Der Auftragsersteller speichert lokal, dass diese ID zu diesem Auftrag und diesem Kontakt gehört.
2. Der Nutzer versendet das Paket selbst per Messenger (z. B. Signal). Es gibt **keine Server-Datenspeicherung**.
3. Der Subunternehmer **importiert** das Paket in seine App und erhält die Auftragsdetails. Dabei trägt er **seinen Namen** ein (idealerweise aus seinem App-Profil vorbefüllt). Der Name dient zur Anzeige und als Plausibilitätsprüfung. Die eigentliche Zuordnung beim Rücklauf erfolgt über die Paket-ID (siehe Schritt 6).
4. Der Subunternehmer erfasst in der App:
   - **Arbeitszeit** (integrierte Zeiterfassung per Button):
     - **Start:** bei Ankunft auf der Baustelle
     - **Pause:** bei Beginn einer Pause (die Zeiterfassung wird pausiert)
     - **Ende:** bei Arbeitsende
   - nach Beendigung der Arbeit: **Fotos** („Nachher-Bilder"), **Videos**, **Sprachmemos** sowie **Text** (Anmerkungen)
5. Diese Informationen werden zusammen mit dem **Namen des Subunternehmers** und der **Paket-ID** als Datenpaket **zurück an den Auftragsersteller** gesendet.
6. Der Auftragsersteller importiert das Paket. Die App **erkennt den Absender automatisch**: Anhand der Paket-ID ordnet sie das Rückpaket dem ursprünglich geteilten Auftrag und dem Kontakt zu, an den der Auftrag geteilt wurde (Kontakt X). Die Informationen werden **korrekt im zugehörigen Auftragsordner verbucht** und **in den Projekt-/Auftragsordner integriert** (Unterordner *Arbeitsdokumentation*).

> **Hinweis zur Absender-Erkennung:** Die Zuordnung beruht auf der **Paket-ID**, nicht auf der Identität des Messenger-Absenders. Die App hat keinen Zugriff auf Messenger-Daten. Wird ein Paket weitergeleitet, würde es trotzdem dem Kontakt X zugeordnet. Der mitgesendete Name des Subunternehmers dient als Plausibilitätsprüfung (siehe Abschnitt 9).

> **Wichtig:** Die Zeiterfassung dient ausschließlich der **Dokumentation** im Auftragsordner. Sie wird **nicht** automatisch in die Personalkosten übernommen. Rechnungen von Subunternehmern kommen separat, üblicherweise per E-Mail, und werden vom Hauptunternehmer importiert (siehe Abschnitte 6.2.2 und 6.5).

---

## 6. Rechnungsverwaltung & Buchhaltung (Extras → Rechnungsverwaltung)

Die Rechnungsverwaltung gliedert sich in die Unterordner **Einnahmen** und **Ausgaben**. Die Ausgaben sind weiter in **Materialkosten** und **Personalkosten** unterteilt. **Jeder dieser drei Ordner enthält ein eigenes Tabellendokument im Format `.xlsx`**, das sich mit LibreOffice Calc o. Ä. öffnen lässt.

Die jeweils genannten Parameter bilden die **Spalten** der Tabelle. Für jede neu erstellte oder importierte Rechnung wird **automatisch eine Zeile** (ein Eintrag) angelegt.

### 6.1 Unterordner `<Einnahmen>`

- Chronologische Ordnung der Einnahmen-Rechnungsdaten
- Funktion: **Rechnungsdaten aus PDF importieren**
- **Tabellendokument `Einnahmen.xlsx`** mit den Spalten:

| Datum | Kundenname | Adresse | Auftragstitel | Rechnungsnummer | Summe brutto | Summe netto |
|---|---|---|---|---|---|---|

### 6.2 Unterordner `<Ausgaben>`

Die Ausgaben gliedern sich in **zwei getrennte Unterordner**. Beide sind chronologisch geordnet und bieten die Funktion **Rechnungsdaten aus PDF importieren**.

#### 6.2.1 Unterordner `<Materialkosten>`

- **Tabellendokument `Materialkosten.xlsx`** mit den Spalten:

| Datum | Rechnungssteller | Summe brutto | Summe netto |
|---|---|---|---|

- **Kein Auftragsbezug nötig:** Importierte Materialrechnungen brauchen **keinen Auftrag**. Sie liegen direkt in diesem Ordner. Optional kann der Nutzer sie zusätzlich einem Auftrag zuordnen (siehe Abschnitt 6.4).
- **Beleg per Kamera erfassen:** Zusätzlich zum PDF-Import kann der Nutzer **Betriebsausgaben per Foto** hinzufügen. Der Button „Beleg fotografieren" öffnet die Kamera. Das Foto wird lokal in diesem Ordner gespeichert, und es wird eine Zeile in `Materialkosten.xlsx` angelegt.
  - **Stufe 1 (Basis):** Der Nutzer trägt Datum, Rechnungssteller und Beträge in einem kurzen Formular selbst ein. Das Foto dient als Beleg.
  - **Stufe 2 (optional, später):** Automatisches Auslesen des Fotos per **Texterkennung direkt auf dem Gerät** (ohne Cloud). Bei schlecht fotografierten Belegen ist das weniger zuverlässig als das PDF-Auslesen. Deshalb gibt es immer eine Kontrolle durch den Nutzer vor dem Speichern.

#### 6.2.2 Unterordner `<Personalkosten>`

- **Tabellendokument `Personalkosten.xlsx`** mit den Spalten:

| Datum | Name | Auftrag | Stunden | Stundenlohn | Summe brutto | Summe netto |
|---|---|---|---|---|---|---|

> In diesen Ordner kommen **ausschließlich selbst importierte Rechnungen**, vor allem die Rechnungen der Subunternehmer. Sie schicken diese üblicherweise per E-Mail an den Hauptunternehmer, der sie hier importiert. Die Rechnung wird automatisch ausgelesen und als neue Zeile in `Personalkosten.xlsx` übernommen. Die **Zeiterfassung** aus Abschnitt 5 wird **nicht** übernommen, sie dient nur der Dokumentation.

- **Auftragsbezug optional:** Subunternehmer-Rechnungen brauchen **nicht notwendigerweise einen Auftrag**. Die Zuordnung zu einem Auftrag wird angeboten, ist aber nicht verpflichtend. Ohne Auftrag bleibt die Spalte *Auftrag* leer.

### 6.3 Automatische Einträge

- **Eigene Rechnung:** Wird unter *Kunden → Aufträge* eine Rechnung erstellt, wird sie **nach Bestätigung durch den Nutzer** unter *Einnahmen* abgelegt. Zusätzlich entsteht automatisch ein Eintrag (eine neue Zeile) in `Einnahmen.xlsx`.
- **PDF-Import:** Importierte PDFs (Einnahmen, Materialkosten oder Personalkosten) werden **ausgelesen**. Die Informationen werden extrahiert und als neue Zeile in das **jeweilige** Tabellendokument übertragen.
- Ziel: Alle Rechnungsdaten sind übersichtlich zusammengefasst und lokal gespeichert, auch als Grundlage für Betriebsausgaben, Einnahmen und MwSt.

### 6.4 Speicherort und Verweise

Rechnungen erscheinen an mehreren Stellen der App (siehe Abschnitt 3.6). Dafür gilt: **Verweise statt Dateikopien.** Jede Rechnungsdatei existiert genau einmal.

- **Kanonischer Speicherort:** Eine Rechnungsdatei liegt dort, wo ihr Hauptbezug ist:
  - **Rechnung mit Auftragsbezug** (eigene Rechnungen, Subunternehmer-Rechnungen mit Auftrag): **physisch im Auftragsordner unter `Rechnungen/`**. Der Auftragsordner ist das Zentrum des Projekts und bleibt so auch im Dateimanager vollständig und intuitiv.
  - **Materialrechnung ohne Auftragsbezug** (PDF oder Beleg-Foto): **physisch unter `Rechnungsverwaltung/Ausgaben/Materialkosten/`**.
  - **Subunternehmer-Rechnung ohne Auftragsbezug**: **physisch unter `Rechnungsverwaltung/Ausgaben/Personalkosten/`**.
- **Tabellendokumente (`.xlsx`):** Sie enthalten die **Datenzeilen** der Rechnungen (Datum, Beträge usw.) und verweisen auf die zugehörige Datei.
- **Weitere Ansichten** (Kunden → Rechnungsordner, Kollegen → Person, Rechnungsverwaltung → Einnahmen / Materialkosten / Personalkosten) sind **reine Ansichten der App** auf dieselbe Datei.
- **Materialrechnungen ohne Auftrag:** Importierte Materialrechnungen (PDF oder Beleg-Foto) brauchen **keinen Auftragsbezug**. Sie liegen direkt unter `Rechnungsverwaltung/Ausgaben/Materialkosten/`. Eine Zuordnung zu einem Auftrag ist optional möglich. Wird sie gewählt, bleibt die Datei trotzdem an einem Ort, der Auftragsordner zeigt sie nur als Verweis.
- **Subunternehmer-Rechnungen ohne Auftrag:** Auch sie brauchen **keinen Auftragsbezug**. Die App bietet beim Import die Zuordnung zu einem Auftrag an, verlangt sie aber nicht. Ohne Zuordnung liegt die Datei unter `Rechnungsverwaltung/Ausgaben/Personalkosten/`. Die Rechnung bleibt der Person unter *Kollegen* zugeordnet.
- **Importierte Einnahmen ohne erkennbaren Auftrag:** Hier fragt die App beim Import nach der Zuordnung. Das weitere Vorgehen, wenn keine Zuordnung möglich ist, ist offen (siehe Abschnitt 9).
- **Rechnungs-ID:** Die interne Registrierung einer Rechnung mit ID findet nur bei **eigenen Aufträgen** statt. Die Rechnungsnummer gibt der Nutzer im Formular „Rechnung erstellen" selbst ein (siehe Abschnitt 4.5). Importierte Rechnungen übernehmen die Nummer aus dem PDF, soweit erkannt.

### 6.5 Import-Funktionen (wo Rechnungen importiert werden können)

Der Import einer Rechnung (PDF) wird an **mehreren Stellen** angeboten. Die Rechnung wird dabei jeweils automatisch ausgelesen und als neue Zeile in die passende `.xlsx` übernommen.

| Ort | Zweck | Vorbefüllt |
|---|---|---|
| Extras → Rechnungsverwaltung → **Einnahmen** | Rechnungen an Kunden, die nicht in der App erstellt wurden | Tabelle: `Einnahmen.xlsx` |
| Extras → Rechnungsverwaltung → Ausgaben → **Materialkosten** | Materialrechnungen (PDF-Import oder **Beleg-Foto per Kamera**), ohne Auftragsbezug | Tabelle: `Materialkosten.xlsx` |
| Extras → Rechnungsverwaltung → Ausgaben → **Personalkosten** | Rechnungen der Subunternehmer (kommen üblicherweise per E-Mail), auch ohne Auftragsbezug | Tabelle: `Personalkosten.xlsx` |
| Auftragsordner → **Rechnungen** | Import direkt im Kontext eines Auftrags | Auftrag ist bereits zugeordnet |
| Kollegen → Person → **Rechnungen** | Import einer Rechnung dieser Person (z. B. eines Subunternehmers) | Person ist bereits zugeordnet, Auftrag optional; Tabelle: `Personalkosten.xlsx` |

> Der Import unter *Kollegen → Person* ist vom Auftraggeber bestätigt. Die Zuordnung zu einem Auftrag wird angeboten, ist aber nicht verpflichtend (siehe Abschnitt 6.4).

---

## 7. Vorlagensystem (Extras → Rechnungsvorlage / Angebotsvorlage)

> **Kritischer Funktionsbereich:** Dieses System muss zuverlässig funktionieren. Jeder Unternehmer baut seine Rechnung ein wenig anders auf.

- Der Nutzer lädt seine **individuelle Rechnungsvorlage** bzw. **Angebotsvorlage** als **`.docx`** hoch.
- Der Nutzer **legt die Variablen selbst fest**, z. B. Menge / Faktor / Position / … Er **markiert sie mit Platzhaltern in der Datei**.
- Die App liest die Platzhalter aus der Vorlage und bildet daraus das Eingabeformular (Rechnungsparameter) unter *Kunden → Aufträge → Rechnung erstellen*.
- Beim Erzeugen befüllt der `.docx`-Mapper (`lib/services/`) die Platzhalter mit den Kunden-, Auftrags- und Kalkulationsdaten.
- Ausgabe als **`.pdf` oder `.docx`**
- Dieselbe Logik gilt für **Angebote** (Angebotsvorlage).

---

## 8. Lokale Ordnerstruktur auf dem Gerät

Die Struktur spiegelt die App-Struktur wider. Der Nutzer soll seine Daten auch im Dateimanager einfach und intuitiv wiederfinden (Vorschlag, vom Auftraggeber grundsätzlich bestätigt; um die Rechnungsverwaltung ergänzt):

```
Galabau-Daten/
├── Kunden/
│   └── <Kundenname>/                  (Kundenordner)
├── Aufträge/
│   └── <Auftragstitel>/               (Auftragsordner)
│       ├── Auftragsdetails/           (Beschreibung, Dateien, Notizen, Anmerkungen)
│       ├── Arbeitsdokumentation/      (Nachher-Bilder, Zeiterfassung, Anmerkungen)
│       ├── Assoziierte Rechnungen/    (Materialkosten, Subunternehmer, PDF-Import)
│       └── Rechnungen/                (Kalkulation, erstellte Rechnungen; Speicherort der Rechnungs-Dateien, siehe 6.4)
├── Rechnungsverwaltung/
│   ├── Einnahmen/                     (chronologisch; inkl. Einnahmen.xlsx)
│   └── Ausgaben/
│       ├── Materialkosten/            (chronologisch; inkl. Materialkosten.xlsx; Materialrechnungen ohne Auftrag und Beleg-Fotos)
│       └── Personalkosten/            (chronologisch; inkl. Personalkosten.xlsx; Subunternehmer-Rechnungen ohne Auftrag)
├── Angebote/
├── Kollegen/                          (Kontaktdaten, Qualifikationen; Rechnungen nur als Verweise)
├── Vorlagen/                          (Rechnungsvorlage.docx, Angebotsvorlage.docx, Platzhalter-Definitionen)
└── Subunternehmer/                    (Datenpakete .galabau)
```

---

## 9. Offene Punkte (Klärungsbedarf, nicht blockierend)

1. **Platzhalter-Syntax** in den `.docx`-Vorlagen (z. B. `{{Kundenname}}`) und wie der Nutzer eigene Variablen definiert.
2. **Tabellendokumente (`.xlsx`):** Wie werden die Dateien lokal geschrieben und aktualisiert? Was passiert, wenn der Nutzer sie parallel in LibreOffice Calc geöffnet hat oder Zeilen manuell ändert?
3. **Personalkosten:** Die Zeiterfassung wird nicht übernommen (geklärt). Offen ist, woher die Spalten *Stunden* und *Stundenlohn* kommen: Sie müssen aus der importierten Rechnung ausgelesen oder vom Nutzer ergänzt werden. Offen ist auch, wie die Zuordnung zum *Namen* (Subunternehmer) erfolgt. Der *Auftrag* ist optional (geklärt).
4. **Verweise (Technik):** Entschieden ist „Verweise statt Kopien" (Abschnitt 6.4). Die Rechnungs-ID-Registrierung für **eigene Rechnungen** gibt es nur bei eigenen Aufträgen. Offen ist, wie **importierte** Rechnungen (Material, Subunternehmer) intern referenziert werden, damit Verweise aus Kollegen, Auftrag und Rechnungsverwaltung stabil bleiben, auch wenn der Nutzer Dateien im Dateimanager umbenennt oder verschiebt (z. B. eine rein interne Referenz ohne Rechnungsnummer-Vergabe).
5. **Import ohne Auftrag:** Für Material- und Subunternehmer-Rechnungen ist es geklärt (kein Auftragsbezug nötig). Offen ist nur, was bei importierten Einnahmen (Rechnungen an Kunden) geschieht, wenn keine Zuordnung zu einem Auftrag möglich ist: Ablage ohne Auftragsbezug oder Pflicht zur Zuordnung.
6. **Beleg-Foto (Kamera):** Stufe 1 (Foto + manuelle Eingabe) ist festgelegt. Offen ist, ob und wann Stufe 2 (automatisches Auslesen per Texterkennung auf dem Gerät) umgesetzt wird. Zu klären sind Genauigkeit bei schlecht fotografierten Belegen, Bildqualität und Kameraberechtigung.
7. **Absender-Erkennung (Paket-ID):** Das Rückpaket wird über die Paket-ID dem Auftrag und Kontakt X zugeordnet (Abschnitt 5). Offen ist der Umgang mit Sonderfällen: weitergeleitete Pakete, mehrfach zurückgesendete Pakete, Paket-ID unbekannt (z. B. Auftrag oder Kontakt gelöscht) und abweichender Name im Rückpaket. Offen ist auch, wie der Name im App-Profil hinterlegt und beim Import vorbefüllt wird.
8. **PDF-Auslesen:** Wie zuverlässig ist die Extraktion bei unterschiedlichen Rechnungslayouts? Was passiert bei nicht erkannten Feldern (manuelle Korrektur durch den Nutzer)? Das ist für den Import aller drei Tabellen kritisch (siehe Abschnitt 6.5).
9. **PDF-Erzeugung:** Wie wird aus der `.docx`-Vorlage lokal ein PDF erzeugt (ohne Cloud-Dienst)?
10. **Ordnerstruktur:** Liegen Auftragsordner top-level (`Aufträge/`) oder unter dem jeweiligen Kundenordner? Die Skizze legt nahe, dass der Auftragsordner beim Anlegen eines Auftrags zu einem Kunden entsteht.
11. **Subunternehmer-Flow:** Ein weiteres Flowdiagramm ist laut Auftraggeber nicht nötig. Offen bleibt die Konfliktbehandlung beim Import (siehe Punkt 7). Paketinhalt, Zeiterfassung per Start/Pause/Ende, Name des Subunternehmers und die Absender-Erkennung über die Paket-ID sind festgelegt.
12. **Sicherheit der Datenpakete:** Soll ein `.galabau`-Paket zusätzlich verschlüsselt werden? (Bisher nicht gefordert.)
13. **Diktierfunktion:** Sie muss lokal und offline funktionieren, damit keine Cloud-Abhängigkeit entsteht.
14. **Wetter-Widget:** Die Datenquelle ist zu klären. Eine Online-Abfrage widerspricht ggf. dem strikten Local-First-Prinzip, auch wenn es sich nicht um Kundendaten handelt.
15. **Karte (Open-Street-Map):** Kartenkacheln müssen online geladen werden. Zu klären ist, ob das für die Kartenansicht akzeptabel ist.
16. **Buchhaltung:** Auswertungen (z. B. MwSt.-Übersicht) über die Tabellendokumente hinaus sind bisher nicht spezifiziert.
17. **Umfang des Kalenders:** Aktuell „simpel"; Details (Ansichten, Erinnerungen) sind offen.
18. **Angebote:** Ablageort und Statusverwaltung (z. B. angenommen/abgelehnt) sind nicht spezifiziert.
19. **Schnellaktionen:** Nutzen sie systemweite Mechanismen (Telefon-, Karten- und Mail-App des Geräts)? Das wäre die Variante ohne eigene Cloud-Anbindung. Die Auswahl der Navigations-App trifft dann das Betriebssystem.

---

## 10. Fachliche Entitäten (aus Skizzen & Beschreibung abgeleitet, noch nicht final)

Nur Felder, die der Auftraggeber genannt oder skizziert hat. Die endgültigen Datenmodelle werden vor der Implementierung abgestimmt.

| Entität | Genannte Felder / Inhalte |
|---|---|
| **Kunde** | Name, Adresse, PLZ, Telefon, E-Mail |
| **Auftrag** | Titel, Beschreibung, Erfassungsdatum, Ausführungsdatum (Datum + optional Uhrzeit Anfang/Ende), Status (Offen/Erledigt), wiederkehrend, Medien (Fotos, Videos, Sprachmemos, PDFs), Notizen/Anmerkungen |
| **Kalkulationsposition** | Position, Bezeichnung, Menge, Preis (z. B. 65 €/h), Summe |
| **Kalkulation / Rechnung / Angebot** | Briefkopf, Adressat (Kunde), Rechnungsnr., Datum, Positionen, Summe, MwSt., TOTAL |
| **Kollege** | Kontaktdetails, Qualifikationen (z. B. SKT-A, SKT-B, Hängerführerschein) |
| **Arbeitszeit-Eintrag** | Zeiterfassung zum Auftrag per Button: Start (Ankunft auf der Baustelle), Pause, Ende (Arbeitsende); nur Dokumentation im Auftragsordner, keine Übernahme in die Personalkosten; zugeordnet über die Paket-ID und den Namen des Subunternehmers |
| **Rückmeldung des Subunternehmers** | Paket-ID, Name des Subunternehmers, Fotos („Nachher-Bilder"), Videos, Sprachmemos, Text (Anmerkungen), Arbeitszeit-Einträge; wird über die Paket-ID automatisch dem Auftrag und dem Kontakt zugeordnet |
| **Paket-Zuordnung (lokal beim Auftragsersteller)** | Paket-ID ↔ Auftrag ↔ Kontakt (Subunternehmer); wird beim Teilen angelegt und beim Rücklauf zur Absender-Erkennung genutzt |
| **Rechnungsdatei (Verweisziel)** | Eine PDF-Datei (oder ein Beleg-Foto) an genau einem Ort: im Auftragsordner unter `Rechnungen/` (mit Auftragsbezug) oder unter `Rechnungsverwaltung/Ausgaben/Materialkosten/` (Materialrechnung ohne Auftrag); Querverweise aus Kunde, Kollege, Auftrag und Rechnungsverwaltung (siehe 3.6 und 6.4) |
| **Beleg-Foto** | Foto eines Belegs, aufgenommen mit der Kamera; Ablage in `Ausgaben/Materialkosten/`; Felder werden zunächst manuell erfasst (siehe 6.2.1) |
| **Einnahme (Zeile in `Einnahmen.xlsx`)** | Datum, Kundenname, Adresse, Auftragstitel, Rechnungsnummer, Summe brutto, Summe netto |
| **Materialkosten (Zeile in `Materialkosten.xlsx`)** | Datum, Rechnungssteller, Summe brutto, Summe netto |
| **Personalkosten (Zeile in `Personalkosten.xlsx`)** | Datum, Name, Auftrag (optional), Stunden, Stundenlohn, Summe brutto, Summe netto |
| **Datenpaket (Auftrag an Subunternehmer)** | `.galabau` / ZIP mit Auftragstitel, Adresse, Auftragsbeschreibung inkl. eventueller Bilder, Videos, Sprachmemos und Anmerkungen sowie einer Paket-ID |
| **Datenpaket (Rückmeldung)** | `.galabau` / ZIP mit Paket-ID, Name des Subunternehmers, Fotos, Videos, Sprachmemos und Text (siehe „Rückmeldung des Subunternehmers") |

---

## 11. Design

Vom Auftraggeber festgelegt:

| Entscheidung | Ergebnis |
|---|---|
| **Farbschema** | **Hell** (Light Mode) |
| **Primärfarbe** | **Grün** (Natur, GaLaBau) |
| **Akzentfarben** | erdige **Braun- und Holztöne** |
| **Schrift** | **Inter** (Open Source, SIL OFL). Die Schrift wird als Asset in die App eingebunden und nicht zur Laufzeit geladen (Local-First). |
| **Navigation** | Untere Leiste mit 5 Punkten: Kunden · Kalender · Home · Kollegen · Extras |
| **Statusfarben** | aus der Skizze: **offen = gelb**, **wiederkehrend = blau**, erledigt = Haken |
| **State Management** | **Riverpod** (laut `.clinerules` zulässig) |

### Vorgehen in der Umsetzung

1. **Grundgerüst:** lauffähige App mit der 5-Punkt-Navigation und allen Screens als Gerüst
2. **Referenz-Screen:** der Bereich *Kunden* wird komplett aufgebaut. Daran wird der Look abgestimmt.
3. **Weitere Screens:** nacheinander im gleichen Stil
4. **Fachlogik in Meilensteinen:** Datenmodelle und lokale Speicherung → Kunden und Aufträge → Kalkulation und Rechnung → Rechnungsverwaltung (`.xlsx`) → Vorlagensystem (`.docx`) → Subunternehmer-Pakete (`.galabau`) → Feinschliff
5. **Machbarkeitsproben:** für die riskanten Teile (`.docx`-Vorlagen, `.xlsx`-Schreiben, PDF-Auslesen) vor dem Aufbau darauf

---

## 12. Projektstand

- Flutter-Projekt `galabau_app` mit Grundgerüst: Material 3, helles Theme (Grün/Braun, Inter), untere Navigation mit den 5 Punkten und Gerüst-Screens
- Struktur nach `.clinerules`: `lib/models/`, `lib/views/`, `lib/services/`
- Noch keine Fachlogik und keine lokale Speicherung.
- Referenz-Screen *Kunden* folgt als Nächstes.
