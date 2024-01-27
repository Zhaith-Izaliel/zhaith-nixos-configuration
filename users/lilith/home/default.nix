{
  config,
  pkgs,
  ...
}: {
  # Importing configuration
  imports = [
    ./config/development.nix
    ./config/shell.nix
    ./config/fonts.nix
  ];
}
