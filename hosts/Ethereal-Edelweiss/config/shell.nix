{
  config,
  pkgs,
  ...
}: {
  services.lorri.enable = true;

  # Enable shells
  environment.shells = with pkgs; [zsh bash bashInteractive];
  programs.zsh.enable = true;
}
