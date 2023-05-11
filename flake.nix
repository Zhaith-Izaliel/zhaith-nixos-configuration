{
  description = "Zhaith's NixOS configuation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {nixpkgs, flake-utils, ...}@attrs:
  let
    lib = import ./lib { inputs = attrs; };
  in
  {
    nixosConfigurations = {
      Whispering-Willow = lib.mkSystem {
        hostname = "Whispering-Willow";
        system = "x86_64-linux";
        users = [ "zhaith" ];
      };
      Ethereal-Edelweiss = lib.mkSystem {
        hostname = "Ethereal-Edelweiss";
        system = "x86_64-linux";
        users = [ "lilith" ];
      };
    };
    homeConfigurations = {
      "zhaith@Whispering-Willow" = lib.mkHome {
        username = "zhaith";
        system = "x86_64-linux";
        hostname = "Whispering-Willow";
        stateVersion = "22.05";
      };
      "lilith@Ethereal-Edelweiss" = lib.mkHome {
        username = "lilith";
        system = "x86_64-linux";
        hostname = "Ethereal-Edelweiss";
        stateVersion = "21.05";
      };
    };
  } // flake-utils.lib.eachDefaultSystem
  (system:
  # let
  #   pkgs = import inputs.nixpkgs { inherit system; };
  # in
  {
    # If you're not using NixOS and only want to load your home
    # configuration when `nix` is installed on your system and
    # flakes are enabled.
    #
    # Enable a `nix develop` shell with home-manager and git to
    # only load your home configuration.
    devShells.default = nixpkgs.mkShell {
      buildInputs = with nixpkgs; [ home-manager git ];
      NIX_CONFIG = "experimental-features = nix-command flakes";
    };
  });
}
