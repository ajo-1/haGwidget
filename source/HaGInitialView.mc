import Toybox.WatchUi;
import Toybox.Lang;

// Wird als "echte" Startansicht zurueckgegeben (kein Menu2 direkt),
// weil manche Geraete (z.B. mit Connect IQ 3.3, wie Vivoactive 4S)
// keine native Menu2-Ansicht direkt als Startansicht eines Widgets
// erlauben ("Unexpected Type Error" / "Failed to start CIQ Application").
// Diese leere View wechselt sofort zur eigentlichen Gruppen-Menue-Ansicht.
class HaGInitialView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        WatchUi.pushView(new HaGGroupMenu(), new HaGGroupMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

}
