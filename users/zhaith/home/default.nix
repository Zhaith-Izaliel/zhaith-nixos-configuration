{ config, pkgs, ... }:

{
  # Importing configuration
  imports = [
    ./config/browser.nix
    ./config/development/development.nix
    ./config/development/neovim.nix
    ./config/gnome.nix
    ./config/mail.nix
    ./config/mpd.nix
    ./config/nextcloud.nix
    ./config/shell/kitty.nix
    ./config/shell/shell.nix
    ./config/tools/erd.nix
  ];
}

