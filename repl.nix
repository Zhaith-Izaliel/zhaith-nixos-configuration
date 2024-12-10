let
  nixos = builtins.getFlake "/home/zhaith/Development/gitlab.com/Zhaith-Izaliel/zhaith-nixos-configuration";
  host = "Whispering-Willow";
  user = "zhaith@${host}";
in rec {
  inherit nixos;
  inherit (nixos) inputs nixosConfigurations homeConfigurations;
  mylib = nixos.lib;
  lib = mylib.extend (_: _: inputs.nixpkgs.lib);
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  config = nixosConfigurations.${host}.config;
  options = nixosConfigurations.${host}.options;
  hoptions = homeConfigurations.${user}.options;
  # test = nixos.nixosModules.dev.test {inherit lib pkgs config options;};
}
