{lib}: {
  waybar = import ./waybar.nix {inherit lib;};
  compatibility = import ./compatibility.nix {};
}
