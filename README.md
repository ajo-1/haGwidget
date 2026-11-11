# haGwidget

Home-Assistant-Steuerung für die Venu 4 (Connect IQ Widget). Das Widget ruft
Home-Assistant-Dienste über die REST-API auf (`POST /api/services/<domain>/<dienst>`).
Es enthält **keine feste Geräteliste**: Welche Entities es steuert, steht
ausschließlich in den App-Einstellungen.

Nachfolger des FHEM-Widgets (FhemGWidget), mit eigener App-ID.

## Voraussetzungen

- Garmin Connect IQ SDK mit Venu-4-Unterstützung
- VS Code mit der „Monkey C“-Erweiterung
- Home Assistant, vom Handy aus über **https** erreichbar (die Uhr schickt die
  Anfragen über das Handy und Garmin Connect)

## Projekt aufsetzen (frischer Klon)

`resources/settings/properties.xml` ist nicht im Repository. Einmalig kopieren:

```
copy resources\settings\properties_example.xml.dis resources\settings\properties.xml
```

Außerdem wird der Entwicklerschlüssel `resources/developer_key` gebraucht
(ebenfalls nicht im Repository).

## Einrichtung in der App

1. In Home Assistant ein Zugriffstoken erzeugen: Profil (unten links) →
   Sicherheit → „Langlebige Zugriffstokens“ → Token erstellen. Das Token wird nur
   einmal angezeigt.
2. In der Garmin-Connect-App (oder Garmin Express) die Einstellungen des Widgets
   ausfüllen:
   - **Home-Assistant-URL**, z. B. `https://hass.example.org`
   - **Zugriffstoken** (das Token aus Schritt 1)
   - **Aktionen** (siehe unten)

Das Token steht nie im Quellcode oder im Repository, sondern nur in den
App-Einstellungen.

## Aktionen konfigurieren (ohne neu zu bauen)

Format, eine Aktion pro Eintrag, mit `;` getrennt:

```
Gruppe|Beschriftung|entity_id|Befehl;Gruppe|Beschriftung|entity_id|Befehl;...
```

Beispiel (Platzhalter, bitte durch eigene Entities ersetzen):

```
Lampe|An|light.beispiel|on;Lampe|Aus|light.beispiel|off;Rolladen|Zu|cover.beispiel|close;Rolladen|Auf|cover.beispiel|open
```

Aktionen mit gleicher Gruppe werden zusammengefasst (Reihenfolge wie im Text).

Befehle:

| Befehl | Home-Assistant-Dienst |
|---|---|
| `on` / `off` | `turn_on` / `turn_off` (bei `cover.*`: `open_cover` / `close_cover`) |
| `open` / `close` / `stop` | `open_cover` / `close_cover` / `stop_cover` |
| `toggle` | `toggle` |
| `domain.dienst` | unverändert, z. B. `script.turn_on`, `button.press` |
| anderer Name | wird als Dienst der Entity-Domain verwendet |

Ist das Feld leer, zeigt das Widget nur „Nicht konfiguriert“ und sendet nichts.

## Bedienung

Widget öffnen → Gruppe wählen → Aktion wählen. Der Untertitel zeigt „sende...“,
danach „OK“ oder einen Fehlertext (z. B. „Token ungueltig“, „Entity/Befehl?“).

## Über Garmin Connect installieren (Beta/Store)

1. In VS Code: Befehlspalette → „Monkey C: Export Project“ → ergibt `haGwidget.iq`
   (liegt im gewählten Ordner, wird nicht eingecheckt).
2. Auf https://apps.garmin.com/developer die Datei hochladen, Name und Beschreibung
   eintragen, als Beta bzw. Store-App einreichen.
3. Nach der Freigabe lässt sich die App über Garmin Connect / Connect IQ installieren;
   die Einstellungen (URL, Token, Aktionen) werden dort pro Nutzer eingetragen.

## Dateien

```
manifest.xml                          – Manifest (App-ID, Permission Communications, Produkte)
monkey.jungle                         – Jungle-Datei
resources/strings/strings.xml         – Texte
resources/settings/properties.xml     – App-Einstellungen (URL, Token, Aktionen)
source/HaGApp.mc                      – Einstiegspunkt
source/HaGInitialView.mc              – leere Startansicht, wechselt zum Menü
source/HaGData.mc                     – Einstellung lesen und in Gruppen zerlegen
source/HaGCommands.mc                 – REST-Aufruf an Home Assistant
source/HaGGroupMenu*.mc               – 1. Menüebene (Gruppen)
source/HaGActionMenu*.mc              – 2. Menüebene (Aktionen, sendet Befehl)
source/IdleTimer.mc                   – beendet das Widget nach 30 s ohne Bedienung
```
