with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
  startVmDI = makeDesktopItem rec {
    name = "luminous-rafflesia";
    exec = "start-vm -F";
    icon = "luminous-rafflesia";
    comment = "Luminous Rafflesia - The Windows KVM VM with GPU Passthrough";
    desktopName = "Luminous Rafflesia";
    genericName = "KVM (Luminous Rafflesia)";
    categories = ["Game" "Development" "Graphics"];
  };
  startVmNoLG = makeDesktopItem rec {
    name = "luminous-rafflesia-nolg";
    exec = "start-vm -l";
    icon = "luminous-rafflesia-nolg";
    comment = "Luminous Rafflesia - The Windows KVM VM with GPU Passthrough";
    desktopName = "Luminous Rafflesia (No Looking-Glass)";
    genericName = "KVM NoLG (Luminous Rafflesia)";
    categories = ["Game" "Development" "Graphics"];
  };
  startVmWacom = makeDesktopItem rec {
    name = "luminous-rafflesia-wacom";
    exec = "start-vm --resolution=1920x1080";
    icon = "luminous-rafflesia-wacom";
    comment = "Luminous Rafflesia - The Windows KVM VM with GPU Passthrough";
    desktopName = "Luminous Rafflesia (Wacom)";
    genericName = "KVM Wacom (Luminous Rafflesia)";
    categories = ["Game" "Development" "Graphics"];
  };
in
callPackage ../builder.nix rec {
  pname = "start-vm";

  version = "v1.4.1";

  src = fetchFromGitLab {
    repo = "start-vm";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "0mca7k10i37wds4kq326r2xz3wjpc79rdynyygsxzql1mi27138m";
  };

  buildInputs = [
    bash
  ];

  paths = [
    scream
    virt-manager
    pstree
    libnotify
    looking-glass-client
  ];

  desktopItemPhase = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps

    ln -s ${startVmDI}/share/applications/* $out/share/applications
    ln -s ${startVmNoLG}/share/applications/* $out/share/applications
    ln -s ${startVmWacom}/share/applications/* $out/share/applications

    cp share/icons/* $out/share/icons/hicolor/512x512/apps
  '';
}
