import Toybox.Lang;
import Toybox.WatchUi;

class BrightyDelegate extends WatchUi.InputDelegate {
    var _view;

    function initialize(v as WatchUi.View) {
        WatchUi.InputDelegate.initialize(); // inicializuj správného předka
        _view = v;
    }

    // předávám klávesy do View
    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        // pošli do View, které má onKey(key as Ui.Key)
        return _view.onKey(keyEvent.getKey());
    }

    // function onMenu() as Boolean {
    //     WatchUi.pushView(new Rez.Menus.MainMenu(), new BrightyMenuDelegate(), WatchUi.SLIDE_UP);
    //     return true;
    // }
}
