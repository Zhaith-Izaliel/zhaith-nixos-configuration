{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.tools;
in
{
  options.hellebore.tools = {
    enable = mkEnableOption "Hellebore tools packages";

    etcher.enable = mkEnableOption "Balena Etcher";
  };

  config = mkIf cfg.enable {

  #   services.input-remapper = {
  #     enable = true;
  #     enableUdevRules = true;
  #     package = (pkgs.input-remapper.overrideAttrs (old: rec {
  #       version = "2.0.1";
  #       src = pkgs.fetchFromGitHub {
  #         owner = "sezanzeb";
  #         repo = "input-remapper";
  #         rev = version;
  #         hash = "sha256-rwlVGF/cWSv6Bsvhrs6nMDQ8avYT80aasrhWyQv55/A=";
  #       };
  #       postPatch = ''
  #       # fix FHS paths
  #       substituteInPlace inputremapper/configs/data.py \
  #       --replace "/usr/share/"  "$out/usr/share/"
  #       '' + ''
  #       # if debugging
  #       substituteInPlace inputremapper/logger.py --replace "logger.setLevel(logging.INFO)"  "logger.setLevel(logging.DEBUG)"
  # '';
  #     })).override { withDebugLogLevel = true; };
  #   };

    environment.systemPackages = with pkgs; [
      gotop
      qview
      ripgrep
      repgrep
      jq
      neofetch
      zip
      unzip
      pstree
      pciutils
      wget
      curl
      tree
      rar
      unrar
      erdtree
      # nix-alien
      file
    ] ++ lists.optional cfg.etcher.enable pkgs.etcher;

    programs.nix-ld.enable = true;
  };
}

