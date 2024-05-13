let
  nixos = builtins.getFlake "/home/zhaith/Development/gitlab.com/Zhaith-Izaliel/zhaith-nixos-configuration";
  host = "Ethereal-Edelweiss";
in rec {
  inherit nixos;
  inherit (nixos) inputs nixosConfigurations;
  mylib = nixos.lib;
  lib = mylib.extend (_: _: inputs.nixpkgs.lib);
  pkgs = inputs.nixpkgs-stable.legacyPackages.x86_64-linux;
  config = nixosConfigurations.${host}.config;
  options = nixosConfigurations.${host}.options;
  # test = nixos.nixosModules.dev.test {inherit lib pkgs config options;};
}
