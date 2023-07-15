{ ... }:

{
  services.xserver = {
    enable = true;

    displayManager.sddm.sugarCandy = {
      enable = true;
      settings = {
        ScreenWidth = 1920;
        ScreenHeight = 1080;
        FormPosition = "left";
      };
    };
  };
}

