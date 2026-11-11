import Toybox.WatchUi;
import Toybox.Lang;

// Reagiert auf Auswahl einer konkreten Aktion: ruft den Home-Assistant-Dienst auf
// und zeigt das Ergebnis (OK / Fehlertext) direkt als Untertitel des Menuepunkts an.
class HaGActionMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _pendingItem as WatchUi.MenuItem or Null;

    function initialize() {
        Menu2InputDelegate.initialize();
        _pendingItem = null;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        IdleTimer.reset();
        var action = item.getId() as Dictionary;
        _pendingItem = item;
        item.setSubLabel("sende...");
        WatchUi.requestUpdate();

        HaGCommands.send(
            action.get("device") as String,
            action.get("cmd") as String,
            method(:onResponse)
        );
    }

    // Kurztexte fuer den Untertitel.
    // -400/-402: Home Assistant antwortet auf einen Dienstaufruf mit einer JSON-Liste;
    // kann die Uhr diese nicht als Antwort einlesen, war der Aufruf trotzdem erfolgreich.
    // Fehler beim Zugriff (falsches Token, falsche Entity) kommen als 401/404.
    function describe(code as Number) as String {
        if (code == 200 || code == 201 || code == -400 || code == -402) {
            return "     OK";
        } else if (code == 401) {
            return "Token ungueltig";
        } else if (code == 404) {
            return "Entity/Befehl?";
        } else if (code == 400) {
            return "Befehl ungueltig";
        } else if (code == HaGCommands.ERR_NO_URL) {
            return "URL fehlt";
        } else if (code == HaGCommands.ERR_NO_TOKEN) {
            return "Token fehlt";
        } else if (code == HaGCommands.ERR_NO_ACTION) {
            return "Nicht konfiguriert";
        } else if (code == -104) {
            return "Kein Handy";
        } else if (code == -1001) {
            return "https noetig";
        }
        return "   Fehler " + code.toString();
    }

    function onResponse(responseCode as Number, data as Dictionary or String or Null) as Void {
        if (_pendingItem == null) {
            return;
        }
        _pendingItem.setSubLabel(describe(responseCode));
        WatchUi.requestUpdate();
    }

}
