{ pkgs, ... }:

let
  cursorThemeName = "Catppuccin-Macchiato-Dark-Cursors";
in
{
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Macchiato-Standard-Sapphire-Dark";
      package = pkgs.catppuccin-gtk.override {
      accents = [ "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach"
      "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow" ];
      size = "standard";
      variant = "macchiato";
    };
    };

    cursorTheme = {
      name = "${cursorThemeName}";
      package = pkgs.catppuccin-cursors.macchiatoDark;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell Regular";
      size = 14;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };


  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    systemdIntegration = true;
    extraConfig = ''
      exec-once=hyprctl setcursor ${cursorThemeName} 32
    '';
    plugins = [

    ];
  };
}

