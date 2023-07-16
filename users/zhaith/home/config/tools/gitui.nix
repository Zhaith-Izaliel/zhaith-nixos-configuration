{ theme, ... }:

{
  programs.gitui = {
    inherit (theme.gitui-theme.gitui) theme;
    enable = true;
  };
}

