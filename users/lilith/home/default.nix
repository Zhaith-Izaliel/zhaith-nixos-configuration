{...}: {
  hellebore = {
    theme.name = "catppuccin-macchiato";
    font.size = 12;

    dev-env = {
      helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          languages = {
            language-server.nixd.config.nixd = {
              nixpkgs.expr = ''import (builtins.getFlake "gitlab:Zhaith-Izaliel/zhaith-nixos-configuration").inputs.nixpkgs-unstable {}'';
              options = {
                nixos.expr = ''(builtins.getFlake "gitlab:Zhaith-Izaliel/zhaith-nixos-configuration").nixosConfigurations.Whispering-Willow.options'';
                home_manager.expr = ''(builtins.getFlake "gitlab:Zhaith-Izaliel/zhaith-nixos-configuration").homeConfigurations."zhaith@Whispering-Willow".options'';
              };
            };
          };
        };
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
