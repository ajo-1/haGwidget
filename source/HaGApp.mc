import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class HaGApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary or Null) as Void {
        IdleTimer.start();
    }

    function onStop(state as Dictionary or Null) as Void {
    }

    // Startansicht: eine leere View, die sofort zur Gruppen-Menue-Ansicht
    // wechselt. Manche Geraete (Connect IQ 3.3, z.B. Vivoactive 4S) erlauben
    // keine native Menu2-Ansicht direkt als Startansicht eines Widgets.
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new HaGInitialView()] as [WatchUi.Views];
    }

}
