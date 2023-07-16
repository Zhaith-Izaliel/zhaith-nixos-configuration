{ theme, ... }:

{
  services.xserver = {
    enable = true;
    layout = "fr";
    xkbVariant = "oss_latin9";

    displayManager.sddm.sugarCandy = {
      inherit (theme.sddm-theme.sddm) settings;
      enable = true;
    };
  };
}

