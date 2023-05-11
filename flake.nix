{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, inputs }:
  let
    lib = import ./lib { inherit inputs self; };
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
        stateVersion = "";
      };
      "lilith@Ethereal-Edelweiss" = lib.mkHome {
        username = "lilith";
        system = "x86_64-linux";
        hostname = "Ethereal-Edelweiss";
        stateVersion = "";
      };
    };
  } // inputs.flake-utils.lib.eachDefaultSystem
  (system:
  let
    pkgs = import inputs.nixpkgs { inherit system; };
  in
  {
          # If you're not using NixOS and only want to load your home
          # configuration when `nix` is installed on your system and
          # flakes are enabled.
          #
          # Enable a `nix develop` shell with home-manager and git to
          # only load your home configuration.
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [ home-manager git ];
            NIX_CONFIG = "experimental-features = nix-command flakes";
          };
        }
        );
      }
