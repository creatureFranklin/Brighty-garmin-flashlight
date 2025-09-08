using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Math;
import Toybox.Lang;

module UiUtils {
    /**
     * Draws a short arc along the edge plus an optional icon.
     * angleDeg = the central angle in degrees (0° is to the right, increases anticlockwise)
     */
    function drawSoftKeyStrip(
        dc as Gfx.Dc, // drawing context
        cx, // center X
        cy, // center Y
        r as Lang.Numeric, // radius of the ring
        angleDeg as Lang.Numeric, // central angle of the segment
        arcLenDeg as Lang.Numeric, // length of the segment (in degrees)
        ringWidth as Lang.Numeric, // thickness of the ring
        bgColor as Lang.Numeric, // background color (fills the ring)
        segColor as Lang.Numeric // color of the short arc (e.g. Graphics.COLOR_BLACK)
    ) as Void {
        var startDeg = angleDeg - arcLenDeg / 2.0;
        var endDeg = angleDeg + arcLenDeg / 2.0;

        dc.setPenWidth(ringWidth);
        dc.setColor(segColor, bgColor);
        dc.drawArc(cx, cy, r, Gfx.ARC_COUNTER_CLOCKWISE, startDeg, endDeg);
    }

    function drawLabel(
        dc as Gfx.Dc,
        cx as Numeric,
        cy as Numeric,
        angleDeg as Numeric,
        r as Numeric,
        text as String,
        fg as Gfx.ColorType,
        bg as Gfx.ColorType,
        font as Gfx.FontDefinition,
        offset as Numeric
    ) {
        var rad = (angleDeg * Math.PI) / 180.0;
        var rIcon = r - offset;
        var x = cx + rIcon * Math.cos(rad);
        var y = cy - rIcon * Math.sin(rad);

        dc.setColor(fg, bg);
        dc.drawText(x, y, font, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }
}
