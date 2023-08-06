{ pkgs }:

{
  double-display = import ./double-display { inherit pkgs; };

  nix-npm-install = import ./nix-npm-install { inherit pkgs; };

  start-vm = import ./start-vm { inherit pkgs; };

  power-management = import ./power-management { inherit pkgs; };

  dim-on-lock = import ./dim-on-lock { inherit pkgs; };

  wlogout-blur = import ./wlogout-blur { inherit pkgs; };

  toggle-bluetooth = import ./toggle-bluetooth { inherit pkgs; };

  volume-brightness = import ./volume-brightness { inherit pkgs; };
}

