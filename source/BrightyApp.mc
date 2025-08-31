using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;

class BrightyApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {}

    function getInitialView() {
        var v = new FlashlightView();
        var d = new BrightyDelegate(v);
        return [v, d];
    }
}
