{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.commitlint;
  commitlintrc = ''
    module.exports = {
      extends:
      [
        '${cfg.conventionalConfigPackage}/lib/node_modules/@commitlint/config-conventional'
      ],
      formatter: '@commitlint/format',
      parserPreset: undefined,
      ignores: undefined,
      defaultIgnores: undefined,
      plugins: [],
      rules: {},
      helpUrl: 'https://github.com/conventional-changelog/commitlint/#what-is-commitlint',
      prompt: {}
    }
    '';

in
  {
  options.hellebore.commitlint = {
    enable = mkEnableOption "Enable Commitlint with the Hellebore
    configuration";

    commitlintrc = mkOption {
      type = types.str;
      default = commitlintrc;
      description = "Override the default commitlintrc config.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.commitlint;
      description = "The Commitlint package.";
    };

    conventionalConfigPackage = mkOption {
      type = types.packages;
      default = pkgs.commitlint-config-conventional;
      description = "The Commitlint Config Conventional package.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      cfg.conventionalConfigPackage
    ];

    home.file.".commitlintrc" = cfg.commitlintrc;
  };
}

