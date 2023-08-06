{ theme, ... }:

{
  imports = [
    ../../../../../assets/kitten
  ];

  programs = {
    kitty = {
      inherit (theme.kitty-theme.kitty) theme font settings keybindings;
      enable = true;
    };
  };
}

