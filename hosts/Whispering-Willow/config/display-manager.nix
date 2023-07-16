{ theme, ... }:

{
  services.xserver = {
    enable = true;
    layout = "fr";
    xkbVariant = "oss_latin9";

    displayManager.sddm.sugarCandyNix = {
      inherit (theme.sddm-theme.sddm) settings;
      enable = true;
    };
  };
}

