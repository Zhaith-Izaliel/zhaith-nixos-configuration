{ pkgs }:

{
  double-display = import ./double-display { inherit pkgs; };

  nix-npm-install = import ./nix-npm-install { inherit pkgs; };

  start-vm = import ./start-vm { inherit pkgs; };

  power-management = import ./power-management { inherit pkgs; };
}

