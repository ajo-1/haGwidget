import Toybox.WatchUi;
import Toybox.Lang;

// Zweite Menueebene: die Aktionen innerhalb einer Gruppe (z.B. Zu/Auf, An/Aus).
class HaGActionMenu extends WatchUi.Menu2 {

    function initialize(group as Dictionary) {
        Menu2.initialize({ :title => group.get("label") as String });

        var actions = group.get("actions") as Array;
        for (var i = 0; i < actions.size(); i += 1) {
            var action = actions[i];
            addItem(new WatchUi.MenuItem(
                action.get("label") as String,
                null,
                action,
                { :alignment => WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT }
            ));
        }
    }

}
