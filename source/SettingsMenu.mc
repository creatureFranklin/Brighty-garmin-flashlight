using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
import Toybox.Lang;
using Toybox.System;

// ---------- Pevná ID položek (Symbol) ----------
class SettingsIds {
    public static const COLOR_IDS = [:color0, :color1, :color2, :color3, :color4, :color5];
    public static const TIMEOUT_IDS = [:timeout0, :timeout1, :timeout2, :timeout3, :timeout4, :timeout5, :timeout6];

    public static const ID_COLOR = :color; // hlavní menu → podmenu barev (multiselect)
    public static const ID_SAVE_COLORS = :save; // hlavní menu -> podmenu barev "Uložit"
    public static const ID_HINTS = :hints; // hlavní menu toggle
    public static const ID_TIMEOUT = :timeout; // hlavní menu → podmenu timeout
    public static const ID_BACK = :back; // univerzální "Zpět"
}

// ---------- Model: načítání/ukládání nastavení ----------
class SettingsModel {
    public var colorLabels = ["White", "Green", "Red"]; // TODO: Dark gray, Light gray
    public var colorValues = [Graphics.COLOR_WHITE, Graphics.COLOR_GREEN, Graphics.COLOR_RED];

    public var timeoutLabels = ["Never", "5 s", "10 s", "30 s", "60 s"];
    public var timeoutValues = [0, 5, 10, 30, 60];

    // ---- MULTISELECT BARVY ----
    function getSelectedColors() {
        var arr = Application.getApp().getProperty("mainColors");
        if (arr == null) {
            // Default: aspoň jedna barva
            arr = [Graphics.COLOR_WHITE];
        }
        return arr;
    }

    function setSelectedColors(list) {
        Application.getApp().setProperty("mainColors", list);
    }

    function isColorSelected(val as Number) {
        var sel = getSelectedColors();
        for (var i = 0; i < sel.size(); i += 1) {
            if (sel[i] == val) {
                return true;
            }
        }
        return false;
    }

    function toggleColor(val as Number) {
        var sel = getSelectedColors();

        if (isColorSelected(val)) {
            sel.remove(val);
        } else {
            sel.add(val);
        }

        // Bezpečnost: vždy aspoň 1 barva
        if (sel.size() == 0) {
            sel.add(Graphics.COLOR_WHITE);
        }

        setSelectedColors(sel);
    }

    // Souhrn pro hlavní menu (krátký text)
    function colorsSummaryLabel() {
        var sel = getSelectedColors();
        var names = [];
        for (var i = 0; i < colorValues.size(); i += 1) {
            var cv = colorValues[i];
            var picked = false;
            for (var j = 0; j < sel.size(); j += 1) {
                if (sel[j] == cv) {
                    picked = true;
                    break;
                }
            }
            if (picked) {
                names.add(colorLabels[i]);
            }
        }
        if (names.size() == 0) {
            return "—";
        }
        if (names.size() <= 2) {
            return Utils.joinArray(names, ", ");
        }

        return names.size() + " vybrané";
    }

    // ---- Kompatibilita se single-select (pokud to někde čteš) ----
    function getColor() {
        // Vrací "první" z vybraných, pro starší části aplikace
        var sel = getSelectedColors();
        return sel.size() > 0 ? sel[0] : Graphics.COLOR_WHITE;
    }
    function setColor(c) {
        // Pokud bys někde zavolal setColor, přepíšeme multiselect na jedinou barvu
        setSelectedColors([c]);
    }

    // ---- Další nastavení ----
    function getHints() {
        var v = Application.getApp().getProperty("showHints");
        if (v == null) {
            v = true;
        }
        return v;
    }
    function setHints(on) {
        Application.getApp().setProperty("showHints", on);
    }

    function getAutoOff() {
        var v = Application.getApp().getProperty("autoOffSec");
        if (v == null) {
            v = 0;
        }
        return v;
    }
    function setAutoOff(sec) {
        Application.getApp().setProperty("autoOffSec", sec);
    }

    function indexOfValue(arr, value) {
        for (var i = 0; i < arr.size(); i += 1) {
            if (arr[i] == value) {
                return i;
            }
        }
        return 0;
    }
}

// ---------- Builder menu ----------
class SettingsMenuBuilder {
    private var model;

    function initialize() {
        model = new SettingsModel();
    }

    function buildMainMenu() {
        var m = new WatchUi.Menu();
        m.setTitle("Nastavení");

        // Barvy (multiselect) – ukazuj souhrn
        m.addItem("Barvy: " + model.colorsSummaryLabel(), SettingsIds.ID_COLOR);

        // Hinty
        var hintsTxt = model.getHints() ? "On" : "Off";
        m.addItem("Hinty u tlačítek: " + hintsTxt, SettingsIds.ID_HINTS);

        // Auto-off
        var tIdx = model.indexOfValue(model.timeoutValues, model.getAutoOff());
        m.addItem("Auto-vypnutí: " + model.timeoutLabels[tIdx], SettingsIds.ID_TIMEOUT);

        m.addItem("Zpět", SettingsIds.ID_BACK);
        return m;
    }

    function buildColorMenu(currentSel as Array) {
        var m = new WatchUi.Menu();
        m.setTitle("Barvy (více výběrů)");

        var n = model.colorLabels.size();
        if (n > SettingsIds.COLOR_IDS.size()) {
            n = SettingsIds.COLOR_IDS.size();
        }

        for (var i = 0; i < n; i += 1) {
            var val = model.colorValues[i];
            var picked = false;
            // rychlá kontrola v currentSel
            for (var j = 0; j < currentSel.size(); j += 1) {
                if (currentSel[j] == val) {
                    picked = true;
                    break;
                }
            }
            var mark = picked ? "[x] " : "[ ] ";
            m.addItem(mark + model.colorLabels[i], SettingsIds.COLOR_IDS[i]);
        }

        // Akční tlačítka:
        m.addItem("Uložit", SettingsIds.ID_SAVE_COLORS);
        m.addItem("Zpět", SettingsIds.ID_BACK);
        return m;
    }

    function buildTimeoutMenu() {
        var m = new WatchUi.Menu();
        m.setTitle("Auto-vypnutí");

        var n = model.timeoutLabels.size();
        if (n > SettingsIds.TIMEOUT_IDS.size()) {
            n = SettingsIds.TIMEOUT_IDS.size();
        }

        for (var i = 0; i < n; i += 1) {
            m.addItem(model.timeoutLabels[i], SettingsIds.TIMEOUT_IDS[i]);
        }
        m.addItem("Zpět", SettingsIds.ID_BACK);
        return m;
    }

    // Refresh helpery
    function refreshMainMenu() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        var menu = buildMainMenu();
        var dlg = new SettingsMenuDelegate(self);
        WatchUi.pushView(menu, dlg, WatchUi.SLIDE_IMMEDIATE);
    }

    function refreshColorsMenu(currentSel as Array) {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        var menu = buildColorMenu(currentSel);
        var dlg = new ColorsMenuDelegate(self, currentSel); // předej dál tempSel
        WatchUi.pushView(menu, dlg, WatchUi.SLIDE_IMMEDIATE);
    }
}

// ---------- Delegates ----------
class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {
    private var builder;
    private var model;

    function initialize(b) {
        MenuInputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
    }

    function onMenuItem(item) {
        var startSel = model.getSelectedColors(); // aktuální uložené barvy
        if (item == SettingsIds.ID_COLOR) {
            WatchUi.pushView(builder.buildColorMenu(startSel), new ColorsMenuDelegate(builder, startSel), WatchUi.SLIDE_LEFT);
            return;
        }
        if (item == SettingsIds.ID_SAVE_COLORS) {
            WatchUi.pushView(builder.buildColorMenu(startSel), new ColorsMenuDelegate(builder, startSel), WatchUi.SLIDE_LEFT);
            return;
        }
        if (item == SettingsIds.ID_HINTS) {
            model.setHints(!model.getHints());
            builder.refreshMainMenu();
            return;
        }
        if (item == SettingsIds.ID_TIMEOUT) {
            WatchUi.pushView(builder.buildTimeoutMenu(), new TimeoutMenuDelegate(builder), WatchUi.SLIDE_LEFT);
            return;
        }
        if (item == SettingsIds.ID_BACK) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }
    }

    function onBack() {
        builder.refreshMainMenu();
        return true;
    }
}

class ColorsMenuDelegate extends WatchUi.MenuInputDelegate {
    private var builder;
    private var model;
    private var tempSel; // dočasný výběr

    function initialize(b, initialSel as Array) {
        MenuInputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
        // Vytvoř kopii, aby se do ní klikalo, ale hned se neukládalo
        tempSel = [];
        for (var i = 0; i < initialSel.size(); i += 1) {
            tempSel.add(initialSel[i]);
        }
    }

    // Pomocné funkce na práci s polem bez spolehání na Array.removeAt apod.
    function indexOf(arr as Array, val as Number) as Number {
        for (var i = 0; i < arr.size(); i += 1) {
            if (arr[i] == val) {
                return i;
            }
        }
        return -1;
    }

    function toggleInTemp(val as Number) {
        var idx = indexOf(tempSel, val);
        if (idx >= 0) {
            // smazat
            var newArr = [];
            for (var i = 0; i < tempSel.size(); i += 1) {
                if (i != idx) {
                    newArr.add(tempSel[i]);
                }
            }
            tempSel = newArr;
        } else {
            // přidat
            tempSel.add(val);
        }
        // Bezpečnost: nikdy nenech prázdné? – necháme volné, ale ošetříme při Uložit
    }

    function onMenuItem(item) {
        // Uložit: potvrdit volby a vrátit se do hlavního menu
        if (item == SettingsIds.ID_SAVE_COLORS) {
            if (tempSel.size() == 0) {
                // vždy aspoň jedna barva, default white
                tempSel.add(Graphics.COLOR_WHITE);
            }
            model.setSelectedColors(tempSel);
            builder.refreshMainMenu();
            return;
        }

        // Zpět: zahodit změny (neukládat) a vrátit se
        if (item == SettingsIds.ID_BACK) {
            builder.refreshMainMenu();
            return;
        }

        // Klik na barvu → přepnout v tempSel a refreshnout TOTO podmenu
        var ids = SettingsIds.COLOR_IDS;
        var n = model.colorValues.size();
        if (n > ids.size()) {
            n = ids.size();
        }

        for (var i = 0; i < n; i += 1) {
            if (item == ids[i]) {
                toggleInTemp(model.colorValues[i]);
                builder.refreshColorsMenu(tempSel); // zůstaň v podmenu, ale překresli
                return;
            }
        }
    }

    function onBack() {
        // Back = stejně jako tlačítko Zpět (zahodit změny)
        builder.refreshMainMenu();
        return true;
    }
}

class TimeoutMenuDelegate extends WatchUi.MenuInputDelegate {
    private var builder;
    private var model;

    function initialize(b) {
        MenuInputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
    }

    function onMenuItem(item) {
        if (item == SettingsIds.ID_BACK) {
            builder.refreshMainMenu();
            return;
        }

        var ids = SettingsIds.TIMEOUT_IDS;
        var n = model.timeoutValues.size();
        if (n > ids.size()) {
            n = ids.size();
        }

        for (var i = 0; i < n; i += 1) {
            if (item == ids[i]) {
                model.setAutoOff(model.timeoutValues[i]);
                builder.refreshMainMenu();
                return;
            }
        }
    }

    function onBack() {
        builder.refreshMainMenu();
        return true;
    }
}

// ---------- Jednoduchý vstupní bod ----------
class SettingsMenu {
    static function open() {
        var builder = new SettingsMenuBuilder();
        var menu = builder.buildMainMenu();
        var dlg = new SettingsMenuDelegate(builder);
        WatchUi.pushView(menu, dlg, WatchUi.SLIDE_UP);
    }
}

class SettingsService {
    // Vrátí pole vybraných barev (nikdy prázdné)
    static function getSelectedColors() as Array {
        var arr = Application.getApp().getProperty("mainColors");
        if (arr == null || arr.size() == 0) {
            arr = [Graphics.COLOR_WHITE];
        }
        return arr;
    }

    // „Primární“ barva – první z vybraných (pro místa, kde čekáš jednu barvu)
    static function getPrimaryColor() {
        var arr = getSelectedColors();
        return arr[0];
    }

    // Zda zobrazovat hinty
    static function getHintsEnabled() as Boolean {
        var v = Application.getApp().getProperty("showHints");
        System.println("DEBUG getHintsEnabled: " + v);
        if (v == null) {
            v = true;
        }
        return v;
    }

    // Auto-off v sekundách (0 = nikdy)
    static function getAutoOffSeconds() {
        var v = Application.getApp().getProperty("autoOffSec");
        if (v == null) {
            v = 0;
        }
        return v;
    }
}
