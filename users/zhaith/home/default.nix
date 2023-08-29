{ ... }:

{
  hellebore = {
    desktop-environment = {
      hyprland = {
        enable = true;
        swaylock.enable = true;
        wlogout.enable = true;
        anyrun.enable = true;
        dunst.enable = true;
        waybar.enable = true;
      };
      bluetooth.enable = true;
      network.enable = true;
      cloud.enable = true;
      i18n.enable = true;
      files-manager.enable = true;
      disks.enable = true;
      mail.enable = true;
    };

    tools = {
      discord = {
        enable = true;
        betterdiscord.enable = true;
      };
      office.enable = true;
    };

    multimedia = {
      enable = true;
      art.enable = true;
      obs.enable = true;
      mpd = {
        enable = true;
        enableDiscordRPC = true;
        visualizer = {
          enable = true;
          spectrumSmoothLook = true;
        };
      };
    };

    development = {
      commitlint.enable = true;
      git = {
        enable = true;
        gitui.enable = true;
      };
      erd.enable = true;
      bat.enable = true;
      lorri.enable = true;
    };

    shell = {
      prompt.enable = true;
      emulator.enable = true;
    };
  };
}

