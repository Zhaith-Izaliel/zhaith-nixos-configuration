{...}: {
  hellebore = {
    theme.name = "catppuccin-macchiato";
    font.size = 12;

    dev-env = {
      helix = {
        enable = true;
        defaultEditor = true;
      };
      yazi = {
        enable = true;
        shellIntegrations.zsh = true;
      };
      erdtree.enable = true;
    };

    development = {
      git = {
        enable = true;
        gitui.enable = true;
      };

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
}
