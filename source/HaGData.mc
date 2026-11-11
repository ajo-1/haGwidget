import Toybox.Lang;
import Toybox.Application;

// Zentrale Liste aller steuerbaren Home-Assistant-Entities/Gruppen.
//
// Die Liste kommt ausschliesslich aus der App-Einstellung "haActionsConfig"
// (siehe resources/settings/properties.xml) und kann in Garmin Connect / Garmin
// Express geaendert werden, OHNE die App neu zu bauen. Im Code steht keine
// feste Geraeteliste.
//
// Format (ein Eintrag pro Aktion, mit ";" getrennt):
//   Gruppe|Beschriftung|entity_id|Befehl;Gruppe|Beschriftung|entity_id|Befehl;...
//
// Befehl: on, off, open, close, stop, toggle oder "domain.dienst"
// (siehe HaGCommands.resolve).
//
// Aktionen mit gleicher "Gruppe" werden zusammengefasst (in der Reihenfolge,
// in der sie zuerst auftauchen). Ist die Einstellung leer oder fehlerhaft,
// zeigt die App nur einen Hinweis.
module HaGData {

    function getGroups() as Array<Dictionary> {
        var raw = Application.Properties.getValue("haActionsConfig");
        if (!(raw instanceof Lang.String) || (raw as String).equals("")) {
            return getHintGroups();
        }

        var groups = parseConfig(raw as String);
        if (groups.size() == 0) {
            return getHintGroups();
        }
        return groups;
    }

    // Zerlegt den Konfig-String in Gruppen/Aktionen. Ungueltige oder
    // unvollstaendige Eintraege werden einfach uebersprungen.
    function parseConfig(raw as String) as Array<Dictionary> {
        var groups = [] as Array<Dictionary>;
        var groupIndex = {} as Dictionary;

        var records = splitString(raw, ";");
        for (var i = 0; i < records.size(); i += 1) {
            var rec = records[i];
            if (rec.equals("")) {
                continue;
            }

            var fields = splitString(rec, "|");
            if (fields.size() < 4) {
                continue;
            }

            var groupLabel = fields[0];
            var label = fields[1];
            var entity = fields[2];
            var cmd = fields[3];

            var idx = groupIndex.get(groupLabel);
            if (idx == null) {
                groups.add({
                    "label"   => groupLabel,
                    "actions" => [] as Array<Dictionary>
                });
                idx = groups.size() - 1;
                groupIndex.put(groupLabel, idx);
            }

            var actions = groups[idx as Number].get("actions") as Array<Dictionary>;
            actions.add({
                "label"  => label,
                "device" => entity,
                "cmd"    => cmd
            });
        }

        return groups;
    }

    // Kleiner, abhaengigkeitsfreier String-Split (Monkey C hat kein
    // eingebautes String.split).
    function splitString(str as String, sep as String) as Array<String> {
        var result = [] as Array<String>;
        var rest = str;
        var idx = rest.find(sep);
        while (idx != null) {
            result.add(rest.substring(0, idx as Number) as String);
            rest = rest.substring((idx as Number) + sep.length(), rest.length()) as String;
            idx = rest.find(sep);
        }
        result.add(rest);
        return result;
    }

    // Hinweis, wenn in den App-Einstellungen noch keine Aktionen eingetragen sind.
    // Die Aktion hat keine Entity, sendet also nichts.
    function getHintGroups() as Array<Dictionary> {
        return [
            {
                "label" => "Nicht konfiguriert",
                "actions" => [
                    { "label" => "Aktionen in den App-Einstellungen eintragen", "device" => "", "cmd" => "" }
                ]
            }
        ] as Array<Dictionary>;
    }

}
