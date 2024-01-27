{
  lib,
  colors,
}: let
  converted-colors =
    lib.attrsets.mapAttrs
    (name: value: lib.strings.removePrefix "#" value)
    colors.normal;
in {
  settings = {
    color = converted-colors.base;
    bs-hl-color = converted-colors.rosewater;
    caps-lock-bs-hl-color = converted-colors.rosewater;
    caps-lock-key-hl-color = converted-colors.green;
    inside-color = converted-colors.base;
    inside-clear-color = converted-colors.base;
    inside-caps-lock-color = converted-colors.base;
    inside-ver-color = converted-colors.base;
    inside-wrong-color = converted-colors.base;
    key-hl-color = converted-colors.lavender;
    layout-bg-color = "00000000";
    layout-border-color = "00000000";
    layout-text-color = converted-colors.text;
    line-color = "00000000";
    line-clear-color = "00000000";
    line-caps-lock-color = "00000000";
    line-ver-color = "00000000";
    line-wrong-color = "00000000";
    ring-color = converted-colors.mauve;
    ring-clear-color = converted-colors.rosewater;
    ring-caps-lock-color = converted-colors.peach;
    ring-ver-color = converted-colors.blue;
    ring-wrong-color = converted-colors.maroon;
    separator-color = "00000000";
    text-color = converted-colors.text;
    text-clear-color = converted-colors.rosewater;
    text-caps-lock-color = converted-colors.peach;
    text-ver-color = converted-colors.blue;
    text-wrong-color = converted-colors.maroon;
    indicator-caps-lock = true;
    clock = true;
    indicator = true;
    screenshots = true;
    effect-blur = "30x10";
    timestr = "%H:%M";
    datestr = "%d %b, %Y";
  };
}
