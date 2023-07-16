{ theme, ... }:

{
  services.xserver = {
    enable = true;
    layout = "fr";
    xkbVariant = "oss_latin9";

    displayManager.sddm = {
      inherit (theme.sddm-theme.sddm) settings;
      enable = true;

      sugarCandyNix = {
        inherit (theme.sddm-theme.sugarCandyNix) settings;
        enable = true;
      };
    };
  };
}

