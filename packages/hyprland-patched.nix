{
  stdenv,
  fetchgit,
  lib,
  binutils,
  pciutils,
  writeShellApplication,
  hyprland,
}: let
  # Workarounding wayland insanity https://github.com/swaywm/sway/issues/7645
  accepthack = stdenv.mkDerivation {
    name = "accepthack";

    src = fetchgit {
      url = "https://gitlab.com/retropc/accepthack.git";
      rev = "b3fe022a2ed1d3513888468f5808ee9cff8e7955";
      sha256 = "sha256-Jg4eIHA4Y4oKfjDGeRJeUftlysm0P+2Gn07xN/bSpKM=";
    };

    installPhase = ''
      install -Dm644 accepthack.so $out/lib/accepthack.so
    '';
  };
in
  writeShellApplication {
    name = "hyprland-patched";

    text = ''
      export PATH="''${PATH:-}:${lib.makeBinPath [stdenv.cc binutils pciutils]}"
      ${lib.getLib stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 --preload ${accepthack}/lib/accepthack.so ${hyprland}/bin/.Hyprland-wrapped "$@"
    '';
  }
