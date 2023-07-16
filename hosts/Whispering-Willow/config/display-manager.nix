{ ... }:

{
  services.xserver = {
    enable = true;
    layout = "fr";
    xkbVariant = "oss_latin9";

    displayManager.sddm.sugarCandy = {
      enable = true;
      settings = {
        ScreenWidth = 1920;
        ScreenHeight = 1080;
        FormPosition = "left";
        HaveFormBackground = true;
        PartialBlur = true;
      };
    };
  };
}

