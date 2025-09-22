using Toybox.System;
import Toybox.Lang;

module DeviceButtons {
    /**
     * Check if device has UP physical button
     */
    public function hasUpButton() as Boolean {
        var buttons = System.getDeviceSettings().inputButtons;

        if ((buttons & System.BUTTON_INPUT_UP) != 0) {
            return true;
        }
        return false;
    }

    /**
     * Check if device has DOWN physical button
     */
    public function hasDownButton() as Boolean {
        var buttons = System.getDeviceSettings().inputButtons;

        if ((buttons & System.BUTTON_INPUT_DOWN) != 0) {
            return true;
        }
        return false;
    }
}
