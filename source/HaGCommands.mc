import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

// Ruft einen Home-Assistant-Dienst ueber die REST-API auf:
//   POST <haBaseUrl>/api/services/<domain>/<dienst>
//   Body:   {"entity_id": "<entity>"}
//   Header: Authorization: Bearer <Long-Lived Access Token>
// URL und Token kommen aus den App-Einstellungen (resources/settings/properties.xml),
// nicht aus dem Quellcode.
module HaGCommands {

    // Eigene Fehlercodes (die Garmin-Codes sind 200, 401, -104, ... )
    const ERR_NO_URL = -9001;
    const ERR_NO_TOKEN = -9002;
    const ERR_NO_ACTION = -9003;

    // Uebersetzt Kurzbefehle der Konfiguration in [domain, dienst].
    //   on/off      -> turn_on / turn_off   (bei cover: open_cover / close_cover)
    //   open/close  -> open_cover / close_cover
    //   stop        -> stop_cover
    //   toggle      -> toggle
    //   domain.dienst (z.B. script.turn_on) wird unveraendert uebernommen
    //   alles andere wird als Dienstname der Domain der Entity benutzt (z.B. press)
    function resolve(entity as String, cmd as String) as Array<String> {
        var domain = "homeassistant";
        var dot = entity.find(".");
        if (dot != null) {
            domain = entity.substring(0, dot as Number) as String;
        }

        var cdot = cmd.find(".");
        if (cdot != null) {
            var d2 = cmd.substring(0, cdot as Number) as String;
            var s2 = cmd.substring((cdot as Number) + 1, cmd.length()) as String;
            return [d2, s2] as Array<String>;
        }

        var isCover = domain.equals("cover");
        var service = cmd;
        if (cmd.equals("on")) {
            service = isCover ? "open_cover" : "turn_on";
        } else if (cmd.equals("off")) {
            service = isCover ? "close_cover" : "turn_off";
        } else if (cmd.equals("open")) {
            service = "open_cover";
        } else if (cmd.equals("close")) {
            service = "close_cover";
        } else if (cmd.equals("stop")) {
            service = "stop_cover";
        }
        return [domain, service] as Array<String>;
    }

    function send(entity as String, cmd as String, callback as Method) as Void {
        if (entity.equals("") || cmd.equals("")) {
            callback.invoke(ERR_NO_ACTION, null);
            return;
        }

        var baseValue = Application.Properties.getValue("haBaseUrl");
        var tokenValue = Application.Properties.getValue("haToken");
        if (!(baseValue instanceof Lang.String) || (baseValue as String).equals("")) {
            callback.invoke(ERR_NO_URL, null);
            return;
        }
        if (!(tokenValue instanceof Lang.String) || (tokenValue as String).equals("")) {
            callback.invoke(ERR_NO_TOKEN, null);
            return;
        }

        // Schraegstrich am Ende der URL entfernen
        var url = baseValue as String;
        while (url.length() > 0 && (url.substring(url.length() - 1, url.length()) as String).equals("/")) {
            url = url.substring(0, url.length() - 1) as String;
        }

        var parts = resolve(entity, cmd);
        url = url + "/api/services/" + parts[0] + "/" + parts[1];

        var params = {
            "entity_id" => entity
        } as Dictionary;

        var headers = {
            "Content-Type"  => Communications.REQUEST_CONTENT_TYPE_JSON,
            "Authorization" => "Bearer " + (tokenValue as String)
        } as Dictionary;

        var options = {
            :method       => Communications.HTTP_REQUEST_METHOD_POST,
            :headers      => headers,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        } as Dictionary;

        Communications.makeWebRequest(url, params, options, callback);
    }

}
