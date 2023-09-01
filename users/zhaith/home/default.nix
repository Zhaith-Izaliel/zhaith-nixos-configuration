{ ... }:

{
  hellebore = {
    desktop-environment = {
      hyprland = {
        enable = true;
        lockscreen.enable = true;
        logout.enable = true;
        applications-launcher.enable = true;
        notifications.enable = true;
        status-bar.enable = true;
      };
      bluetooth.enable = true;
      network.enable = true;
      cloud.enable = true;
      i18n.enable = true;
      files-manager.enable = true;
      disks.enable = true;
      mail.enable = true;
      browsers = {
        enable = true;
        profiles.zhaith.enable = true;
      };
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
      git = {
        enable = true;
        gitui.enable = true;
        commitlint.enable = true;
      };
      erdtree.enable = true;
      bat.enable = true;
      tools = {
        enable = true;
        enableLorri = true;
      };
    };

    shell = {
      enable = true;
      prompt.enable = true;
      emulator.enable = true;
    };
  };

  programs.neovim.zhaith-config.enable = true;
}

