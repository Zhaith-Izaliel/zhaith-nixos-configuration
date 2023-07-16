{ pkgs }:

let
  startVmDI = pkgs.makeDesktopItem {
    name = "luminous-rafflesia";
    exec = "start-vm -Fi";
    icon = "luminous-rafflesia";
    comment = "Luminous Rafflesia - The Windows KVM VM with GPU Passthrough";
    desktopName = "Luminous Rafflesia";
    genericName = "KVM (Luminous Rafflesia)";
    startupWMClass = "LuminousRafflesia";
    categories = ["Game" "Development" "Graphics"];
  };
  startVmNoLG = pkgs.makeDesktopItem {
    name = "luminous-rafflesia-nolg";
    exec = "start-vm -li";
    icon = "luminous-rafflesia-nolg";
    comment = "Luminous Rafflesia - The Windows KVM VM with GPU Passthrough";
    desktopName = "Luminous Rafflesia (No Looking-Glass)";
    genericName = "KVM NoLG (Luminous Rafflesia)";
    startupWMClass = "LuminousRafflesia";
    categories = ["Game" "Development" "Graphics"];
  };
in
pkgs.callPackage ../builder.nix rec {
  pname = "start-vm";

  version = "v2.2.0";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-c/FIIYjsbRK3jQeXjN+8EIkoyTa7CmyB2XSwCIAaiMY=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    virt-manager
    pstree
    libnotify
    looking-glass-client
  ];

  desktopItemPhase = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps

    ln -s ${startVmDI}/share/applications/* $out/share/applications
    ln -s ${startVmNoLG}/share/applications/* $out/share/applications

    cp share/icons/* $out/share/icons/hicolor/512x512/apps
  '';
}

