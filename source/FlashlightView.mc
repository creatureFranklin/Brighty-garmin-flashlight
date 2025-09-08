using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
import Toybox.Lang;

class FlashlightView extends WatchUi.View {
    var _colors = Utils.concatenateArray([SettingsService.getSelectedColors(), [Graphics.COLOR_BLACK]]) as Array<Number>;
    var _color as Number;
    var _index as Number = 0;
    // var currentColor as Number;
    var _autoOff as AutoOffController;

    function initialize() {
        View.initialize();
        _color = _colors[_index];

        _autoOff = new AutoOffController(method(:setActiveColor), /*vibrateOnExpire=*/ true);
        _autoOff.rearm(_color);
    }

    function onShow() {
        // znovu slož pole: vybrané barvy + černá
        _colors = Utils.concatenateArray([SettingsService.getSelectedColors(), [Graphics.COLOR_BLACK]]) as Array<Number>;

        // drž index v rozsahu
        var last = _colors.size() - 1;
        if (_index > last) {
            _index = last;
        }
        if (_index < 0) {
            _index = 0;
        }

        // synchronizuj _color s polem a rearmni timer
        setActiveColor(_index);
    }

    function onUpdate(dc as Graphics.Dc) {
        // 1) Fill background
        var bg = _colors[_index];
        var fg = contrastColor(bg);

        dc.setColor(Graphics.COLOR_WHITE, bg);
        dc.clear();

        // 2) Count geometry
        var w = dc.getWidth(),
            h = dc.getHeight();
        var cx = w / 2.0,
            cy = h / 2.0;
        var rOuter = (w < h ? w : h) / 2.0 - 8.0;

        // 3) hints
        var showHintsFlag = SettingsService.getHintsEnabled();

        if (showHintsFlag == true) {
            var last = _colors.size() - 1;
            var canGoNext = _index > 0; // KEY_UP
            var canGoPrev = _index < last; // KEY_DOWN

            if (canGoNext) {
                UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 180, 15, 6, bg, fg);
                UiUtils.drawLabel(dc, cx, cy, 180, rOuter, "+", fg, bg, Graphics.FONT_TINY, 20);
            }

            if (canGoPrev) {
                UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 210, 15, 6, bg, fg);
                UiUtils.drawLabel(dc, cx, cy, 210, rOuter, "-", fg, bg, Graphics.FONT_LARGE, 20);
            }
            UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 30, 15, 6, bg, fg);
        }
    }

    function onKey(key as WatchUi.Key) as Boolean {
        if (key == WatchUi.KEY_ENTER) {
            openSettings();
            return true;
        }
        if (key == WatchUi.KEY_UP) {
            nextColor();
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            prevColor();
            return true;
        }

        return false;
    }

    // TODO: consider if it is good idea
    // function onTap(clickEvent) {
    //     System.println("on tap");
    //     nextColor();
    //     return true;
    // }

    function onHide() {
        if (_autoOff != null) {
            _autoOff.cancel();
        }
    }

    function setActiveColor(colorIndex as Number) as Void {
        _index = colorIndex;
        _color = _colors[_index];
        WatchUi.requestUpdate();
        if (_autoOff != null) {
            _autoOff.rearm(_color); // na černé se timer nespustí
        }
    }

    function nextColor() {
        // KEY_UP
        if (_index > 0) {
            _index -= 1;
            setActiveColor(_index);
        }
    }

    function prevColor() {
        // KEY_DOWN
        var last = _colors.size() - 1;
        if (_index < last) {
            _index += 1;
            setActiveColor(_index);
        }
    }

    /**
     * Opens the app’s internal settings on the watch (implement a SettingsView).
     */
    function openSettings() {
        SettingsMenu.open();
    }

    function contrastColor(bg as Number) as Number {
        if (bg == 0xffffff) {
            return Graphics.COLOR_BLACK;
        } else if (bg == 0xcccccc) {
            return Graphics.COLOR_BLACK;
        } else if (bg == 0x999999) {
            return Graphics.COLOR_WHITE;
        } else if (bg == Graphics.COLOR_RED) {
            return Graphics.COLOR_WHITE;
        } else if (bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_WHITE;
    }
}
