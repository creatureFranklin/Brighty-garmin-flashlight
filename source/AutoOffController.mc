using Toybox.Timer as Timer;
using Toybox.Attention as Attention;
using Toybox.Graphics;
import Toybox.Lang;

class AutoOffController {
    private var _timer as Timer.Timer;
    private var _applyColor as Method; // (Number color) => void
    private var _vibrateOnExp as Boolean;

    function initialize(applyColorFn as Method, vibrateOnExpire as Boolean) {
        _timer = new Timer.Timer();
        _applyColor = applyColorFn;
        _vibrateOnExp = vibrateOnExpire;
    }

    /** Zastaví aktuální odpočet (pokud běží) */
    function cancel() {
        if (_timer != null) {
            _timer.stop();
        }
    }

    /**
     * Znovu ozbrojí timer podle SettingsService.getAutoOffSeconds();
     * Když je currentColor černá, timer NESPUSTÍ.
     */
    function rearm(currentColor as Number) {
        cancel();

        // Na černé barvě nikdy neodpočítáváme:
        if (currentColor == Graphics.COLOR_BLACK) {
            return;
        }

        var sec = SettingsService.getAutoOffSeconds();
        if (sec <= 0) {
            return; // auto-off vypnutý
        }

        _timer.start(method(:_onExpire), sec * 1000, false);
    }

    /** Interní callback po vypršení času */
    function _onExpire() as Void {
        var colors = SettingsService.getSelectedColors();
        System.println("DEBUG: " + colors.size());

        if (_applyColor != null) {
            _applyColor.invoke(colors.size());
        }

        if (_vibrateOnExp) {
            try {
                Attention.vibrate([new Attention.VibeProfile(50, 2000)]);
            } catch (e) {}
        }
    }
}
