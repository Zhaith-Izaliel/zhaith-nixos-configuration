{...}: {
  hellebore = {
    theme.name = "catppuccin-macchiato";
    font.size = 12;

    development = {
      git = {
        enable = true;
        gitui.enable = true;
      };

      erdtree.enable = true;

      bat.enable = true;
      tools = {
        direnv = {
          enable = true;
          enableLogs = true;
        };
      };
    };

    tools.docs.enable = true;

    shell = {
      enable = true;
      prompt.enable = true;
    };
  };

  programs.helix.zhaith-configuration = {
    enable = true;
    defaultEditor = true;
  };
}
