using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer as Timer;
import Toybox.Lang;

class FlashingView extends WatchUi.View {
    // Morse time unit (ms) — SOS: dot=1, dash=3; gaps: element=1, letter=3, word=7
    const UNIT_MS = 250;

    // --- Status ---
    var _colors as Array<Number>;
    var _index as Number = 0;
    var _color as Number;

    var _autoOff as AutoOffController;
    var _timer as Timer.Timer;

    // Sequence: array of [isOn(Boolean), units(Number)]
    var _pattern as Array<Array>;
    var _stepIdx as Number = 0;
    var _remainingUnits as Number = 0;
    var _isOn as Boolean = false;

    // Flashing modes
    public const MODE_SOS as Symbol = :sos;

    function initialize(mode as Symbol) {
        View.initialize();

        _colors = prepareColors();
        _color = _colors[_index];

        _pattern = buildPattern(mode);
        _stepIdx = 0;
        _remainingUnits = _pattern[0][1];
        _isOn = _pattern[0][0];

        _autoOff = new AutoOffController(method(:_applyColorIndexForAutoOff), /*vibrateOnExpire=*/ true);
        _autoOff.rearm(_isOn ? _color : Graphics.COLOR_BLACK);

        _timer = new Timer.Timer();
    }

    function onShow() {
        // Load current user-selected colors (same as in FlashlightView)
        _colors = prepareColors();

        // Start periodic ticking at the UNIT_MS interval
        _timer.start(method(:_tick), UNIT_MS, /*repeat=*/ true);

        WatchUi.requestUpdate();
    }

    function onHide() {
        if (_timer != null) {
            try {
                _timer.stop();
            } catch (e) {}
        }
    }

    function onUpdate(dc as Graphics.Dc) {
        var bg = _isOn ? _colors[_index] : Graphics.COLOR_BLACK;
        var fg = contrastColor(bg);

        dc.setColor(Graphics.COLOR_WHITE, bg);
        dc.clear();

        var w = dc.getWidth(),
            h = dc.getHeight();
        var cx = w / 2.0,
            cy = h / 2.0;
        var rOuter = (w < h ? w : h) / 2.0 - 8.0;

        // 3) hints
        var showHintsFlag = SettingsService.getHintsEnabled();
        // On round displays
        var last = _colors.size() - 1;
        var canGoNext = _index > 0; // KEY_UP
        var canGoPrev = _index < last; // KEY_DOWN

        if (showHintsFlag == true && UiUtils.isRound(dc) == true) {
            if (canGoNext) {
                if (DeviceButtons.hasUpButton()) {
                    UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 180, 15, 6, bg, fg);
                    UiUtils.drawLabelPolar(dc, cx, cy, 180, rOuter, "+", fg, Graphics.FONT_TINY, 20);
                } else {
                    UiUtils.drawLabelRect(dc, "+", fg, Graphics.FONT_LARGE, 0.25, 0);
                }
            }

            if (canGoPrev) {
                if (DeviceButtons.hasDownButton()) {
                    UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 210, 15, 6, bg, fg);
                    UiUtils.drawLabelPolar(dc, cx, cy, 210, rOuter, "-", fg, Graphics.FONT_LARGE, 20);
                } else {
                    UiUtils.drawLabelRect(dc, "-", fg, Graphics.FONT_LARGE, 0.75, 0);
                }
            }
            UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 30, 15, 6, bg, fg);
        }
        // On rect displays
        if (showHintsFlag == true && UiUtils.isRound(dc) == false) {
            if (canGoNext) {
                UiUtils.drawLabelRect(dc, "+", fg, Graphics.FONT_LARGE, 0.25, 0);
            }

            if (canGoPrev) {
                UiUtils.drawLabelRect(dc, "-", fg, Graphics.FONT_LARGE, 0.75, 0);
            }
        }
    }

    function onKey(key as Number) as Boolean {
        if (key == WatchUi.KEY_ENTER) {
            SettingsMenu.open();
            return true;
        }
        if (key == WatchUi.KEY_UP) {
            prevColor();
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            nextColor();
            return true;
        }

        return false;
    }

    // --- Sequence timing ---
    function _tick() as Void {
        // advance timing by 1 unit
        _remainingUnits -= 1;

        if (_remainingUnits <= 0) {
            var len = _pattern.size();
            if (len > 0) {
                // move to next step and wrap
                _stepIdx = (_stepIdx + 1) % len;
                _isOn = _pattern[_stepIdx][0];
                _remainingUnits = _pattern[_stepIdx][1];
            }
        }

        // keep auto-off aligned with current ON/OFF state
        if (_autoOff != null) {
            _autoOff.rearm(_isOn ? _colors[_index] : Graphics.COLOR_BLACK);
        }

        WatchUi.requestUpdate();
    }

    // AutoOffController vyžaduje callback s indexem barvy – držíme kompatibilitu
    function _applyColorIndexForAutoOff(colorIndex as Number) as Void {
        // Use the index within _colors; fallback to black if out of range
        var last = _colors.size() - 1;
        var safeIdx = colorIndex >= 0 && colorIndex <= last ? colorIndex : last;
        _index = safeIdx;
        _color = _colors[_index];
        WatchUi.requestUpdate();
    }

    // --- Mods ---
    function buildPattern(mode as Symbol) as Array<Array> {
        // SOS = ... --- ...
        // dot = 1u ON; gaps: element = 1u, letter = 3u, word = 7u (cycling the “SOS” word here)
        if (mode == MODE_SOS) {
            return [
                // S: ...
                [true, 1],
                [false, 1],
                [true, 1],
                [false, 1],
                [true, 1],
                [false, 3],
                // O: ---
                [true, 3],
                [false, 1],
                [true, 3],
                [false, 1],
                [true, 3],
                [false, 3],
                // S: ...
                [true, 1],
                [false, 1],
                [true, 1],
                [false, 1],
                [true, 1],
                [false, 7], // gap between words before repeating
            ];
        }

        // Default: simple strobe (1u ON / 1u OFF)
        return [
            [true, 1],
            [false, 1],
        ];
    }

    // --- Same color logic as in FlashlightView ---
    function prepareColors() as Array<Number> {
        var settingColors = SettingsService.getSelectedColors();
        var whiteShades = [0xbfbfbf, 0x808080];
        var result = [] as Array<Number>;

        for (var i = 0; i < settingColors.size(); i += 1) {
            var col = settingColors[i];
            result.add(col);

            if (col == Graphics.COLOR_WHITE) {
                for (var j = 0; j < whiteShades.size(); j += 1) {
                    result.add(whiteShades[j]);
                }
            }
        }

        result.add(Graphics.COLOR_BLACK);
        return result;
    }

    function contrastColor(bg as Number) as Number {
        if (bg == 0xffffff) {
            return Graphics.COLOR_BLACK;
        }
        if (bg == 0xcccccc) {
            return Graphics.COLOR_BLACK;
        }
        if (bg == 0x999999) {
            return Graphics.COLOR_WHITE;
        }
        if (bg == Graphics.COLOR_RED) {
            return Graphics.COLOR_WHITE;
        }
        if (bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_WHITE;
    }

    function setActiveColor(colorIndex as Number) as Void {
        _index = colorIndex;
        _color = _colors[_index];
        WatchUi.requestUpdate();
        if (_autoOff != null) {
            _autoOff.rearm(_color);
        }
    }

    function nextColor() {
        var last = _colors.size() - 1;
        if (_index < last) {
            _index += 1;
            setActiveColor(_index);
        }
    }

    function prevColor() {
        if (_index > 0) {
            _index -= 1;
            setActiveColor(_index);
        }
    }
}
