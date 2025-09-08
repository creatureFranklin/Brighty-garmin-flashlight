using Toybox.Application as App;
using Toybox.Graphics as Gfx;
import Toybox.Lang;

module BrightyConfigManager {
    const K_PALETTE = "palette";
    const K_AUTO = "autoOffSec";

    class Config {
        var palette as Array<Number> = [];
        var autoOffSec as Number = 0;
    }

    class ConfigManager {
        // Sestaví paletu z Connect IQ settings (telefon)
        static function buildPaletteFromCIQ() as Array<Number> {
            var a = [];
            var p = App.getApp();

            if (p.getProperty("colorWhite")) {
                a.add(0xffffff);
            }
            if (p.getProperty("colorLightGray")) {
                a.add(0xcccccc);
            }
            if (p.getProperty("colorDarkGray")) {
                a.add(0x999999);
            }
            if (p.getProperty("colorRed")) {
                a.add(Gfx.COLOR_RED);
            }
            if (p.getProperty("colorGreen")) {
                a.add(0x00ff00);
            }

            if (a.size() == 0) {
                a = [0xffffff, Gfx.COLOR_BLACK];
            }
            if (a.indexOf(Gfx.COLOR_BLACK) < 0) {
                a.add(Gfx.COLOR_BLACK);
            }
            return a;
        }

        // Hlavní loader: slije local overrides + CIQ settings
        static function load() as Config {
            var cfg = new Config();

            // --- paleta ---
            var pal = null;

            var localPalVal = App.Properties.getValue(BrightyConfigManager.K_PALETTE);
            if (localPalVal != null) {
                var arr = localPalVal;
                if (arr != null && arr.size() > 0) {
                    pal = arr;
                }
            }
            if (pal == null) {
                pal = ConfigManager.buildPaletteFromCIQ();
            }
            if (pal.indexOf(Gfx.COLOR_BLACK) < 0) {
                pal.add(Gfx.COLOR_BLACK);
            }
            cfg.palette = pal;

            // --- auto-off ---
            var autoSec = 0;

            var localAutoVal = App.Properties.getValue(BrightyConfigManager.K_AUTO);
            if (localAutoVal != null) {
                var n = localAutoVal;
                if (n != null) {
                    autoSec = n;
                }
            } else {
                var ciqVal = App.getApp().getProperty(BrightyConfigManager.K_AUTO);
                if (ciqVal != null) {
                    var n2 = ciqVal;
                    if (n2 != null) {
                        autoSec = n2;
                    } else {
                        var s = ciqVal;
                        if (s != null) {
                            if (s == "0") {
                                autoSec = 0;
                            } else if (s == "15") {
                                autoSec = 15;
                            } else if (s == "30") {
                                autoSec = 30;
                            } else if (s == "60") {
                                autoSec = 60;
                            } else if (s == "120") {
                                autoSec = 120;
                            }
                        }
                    }
                }
            }

            cfg.autoOffSec = autoSec;
            return cfg;
        }

        // Uloží overrides z hodinek
        static function savePalette(pal as Array<Number>) {
            if (pal == null || pal.size() == 0) {
                return;
            }
            if (pal.indexOf(Gfx.COLOR_BLACK) < 0) {
                pal.add(Gfx.COLOR_BLACK);
            }
            App.Properties.setValue(BrightyConfigManager.K_PALETTE, pal);
        }

        static function saveAutoOff(sec as Number) {
            App.Properties.setValue(BrightyConfigManager.K_AUTO, sec);
        }
    }
}
