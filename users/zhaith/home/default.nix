{ ... }:

{
  # Importing configuration
  imports = [
    ./config/browser.nix
    ./config/development.nix
    ./config/gnome.nix
    ./config/mail.nix
    ./config/mpd.nix
    ./config/neovim.nix
    ./config/nextcloud.nix
    ./config/shell/kitty.nix
    ./config/shell/shell.nix
    ./config/tools
  ];
}

