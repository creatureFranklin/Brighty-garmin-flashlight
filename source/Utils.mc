using Toybox.Application as App;
using Toybox.Graphics as Gfx;
import Toybox.Lang;

module Utils {
    function min(a as Number, b as Number) {
        return a < b ? a : b;
    }

    function joinArray(arr as Array, sep as Lang.String) {
        var out = "";
        for (var i = 0; i < arr.size(); i += 1) {
            if (i > 0) {
                out += sep;
            }
            out += arr[i];
        }
        return out;
    }

    // Spojí libovolný počet polí za sebe a vrátí nové pole
    function concatenateArray(arrays as Array<Array>) as Array {
        var result = [];

        for (var i = 0; i < arrays.size(); i += 1) {
            var arr = arrays[i];
            if (arr != null) {
                for (var j = 0; j < arr.size(); j += 1) {
                    result.add(arr[j]);
                }
            }
        }

        return result;
    }
}
