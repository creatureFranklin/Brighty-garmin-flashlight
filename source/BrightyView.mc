using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.Math;
// using Toybox.Attention;

class FlashlightView extends WatchUi.View {
    var _colors as Array<Integer> = [
        0xffffff, // bílá
        0xcccccc, // světle šedá
        0x999999, // tmavší šedá
        Graphics.COLOR_RED, // červená
        Graphics.COLOR_BLACK, // černá
    ];
    var _color as Integer;
    var _index as Integer = 0;

    var _counter as Integer = 0; // jednoduchý timer

    // Button hints
    var _icoUp;
    var _icoDown;

    function initialize() {
        View.initialize();
        _color = _colors[_index];
    }

    function onShow() {}

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
        drawSoftKeyStrip(dc, cx, cy, rOuter, 30, 15, 6, bg, fg);

        drawSoftKeyStrip(dc, cx, cy, rOuter, 180, 15, 6, bg, fg);
        drawLabel(dc, cx, cy, 180, rOuter, "+", fg, bg, Graphics.FONT_TINY, 20);
        drawSoftKeyStrip(dc, cx, cy, rOuter, 210, 15, 6, bg, fg);
        drawLabel(dc, cx, cy, 210, rOuter, "-", fg, bg, Graphics.FONT_LARGE, 20);

        // // 4) timer / animace
        // _counter += 1;
        // if (_counter >= 60) {
        //     _index = (_index + 1) % _colors.size();
        //     _counter = 0;
        // }

        // WatchUi.requestUpdate();
    }

    function onKey(key as WatchUi.Key) as Boolean {
        if (key == WatchUi.KEY_ENTER) {
            System.println("ENTER pressed");
            openSettings();
            return true;
        }
        if (key == WatchUi.KEY_UP) {
            System.println("UP pressed");
            nextColor();
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            System.println("DOWN pressed");
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

    function onHide() {}

    // Pomocné funkce na posun barev
    function nextColor() {
        _index = (_index + 1) % _colors.size();
        WatchUi.requestUpdate();
    }

    function prevColor() {
        _index = (_index - 1 + _colors.size()) % _colors.size();
        WatchUi.requestUpdate();
    }

    // Otevře tvoje interní nastavení na hodinkách (vytvoř si SettingsView)
    function openSettings() {
        WatchUi.pushView(new SettingsView(), null, WatchUi.SLIDE_IMMEDIATE);
    }

    /**
     * Nakreslí krátký oblouk na okraji + volitelnou ikonku.
     * angleDeg = středový úhel ve stupních (0° vpravo, roste proti směru hodin)
     */
    // Nakreslí "negativ": prstenec v bg, krátký segment v segColor (černá)
    function drawSoftKeyStrip(
        dc as Graphics.Dc,
        cx,
        cy, // střed
        r as Lang.Numeric, // poloměr prstence
        angleDeg as Lang.Numeric, // středový úhel segmentu
        arcLenDeg as Lang.Numeric, // délka segmentu (°)
        ringWidth as Lang.Numeric, // tloušťka prstence
        bgColor as Lang.Numeric, // barva pozadí (vyplní prstenec)
        segColor as Lang.Numeric // barva krátkého proužku (např. Graphics.COLOR_BLACK)
    ) as Void {
        var startDeg = angleDeg - arcLenDeg / 2.0;
        var endDeg = angleDeg + arcLenDeg / 2.0;

        // krátký oblouk
        dc.setPenWidth(ringWidth);
        dc.setColor(segColor, bgColor);
        dc.drawArc(cx, cy, r, Graphics.ARC_COUNTER_CLOCKWISE, startDeg, endDeg);
    }

    function drawLabel(
        dc as Graphics.Dc,
        cx as Numeric,
        cy as Numeric,
        angleDeg as Numeric,
        r as Numeric,
        text as String,
        fg as Graphics.ColorType,
        bg as Graphics.ColorType,
        font as Graphics.FontDefinition, // velikost písma
        offset as Numeric // posun směrem ke středu
    ) {
        var rad = (angleDeg * Math.PI) / 180.0;
        var rIcon = r - offset; // vzdálenost od středu
        var x = cx + rIcon * Math.cos(rad);
        var y = cy - rIcon * Math.sin(rad);

        dc.setColor(fg, bg);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function min(a, b) {
        return a < b ? a : b;
    }

    function contrastColor(bg as Number) as Number {
        if (bg == 0xffffff) {
            // bílá
            return Graphics.COLOR_BLACK;
        } else if (bg == 0xcccccc) {
            // světle šedá
            return Graphics.COLOR_BLACK;
        } else if (bg == 0x999999) {
            // tmavší šedá
            return Graphics.COLOR_WHITE;
        } else if (bg == Graphics.COLOR_RED) {
            return Graphics.COLOR_WHITE;
        } else if (bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        // fallback
        return Graphics.COLOR_WHITE;
    }
}
