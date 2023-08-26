{ theme }:

{
  art = import ./art.nix;
  bat = import ./bat.nix { inherit theme; };
  commitlint = import ./commitlint.nix;
  discord = import ./discord.nix;
  erd = import ./erd.nix;
}

