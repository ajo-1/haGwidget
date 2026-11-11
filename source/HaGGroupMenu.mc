import Toybox.WatchUi;
import Toybox.Lang;

// Erste Menueebene: eine Zeile pro Gruppe aus der App-Einstellung.
class HaGGroupMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title => "Home" });

        var groups = HaGData.getGroups();
        for (var i = 0; i < groups.size(); i += 1) {
            var group = groups[i];
            addItem(new WatchUi.MenuItem(
                group.get("label") as String,
                null,
                group,
                { :alignment => WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT }
            ));
        }
    }

}
