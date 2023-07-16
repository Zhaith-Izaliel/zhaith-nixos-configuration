{ ... }:

{
  # Importing configuration
  imports = [
    ./config/browser.nix
    ./config/development.nix
    ./config/mail.nix
    ./config/mpd.nix
    ./config/neovim.nix
    ./config/nextcloud.nix
    ./config/shell
    ./config/tools
    ./config/hyprland.nix
    ./config/i18n.nix
  ];
}

