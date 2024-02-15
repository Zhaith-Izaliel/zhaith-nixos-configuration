{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) concatStringsSep optionalString mkOption mkEnableOption getExe types mkIf;

  cfg = config.hellebore.shell.emulator;
  emulator-bin = concatStringsSep " " [
    (optionalString cfg.integratedGPU.enable
      "MESA_LOADER_DRIVER_OVERRIDE=${cfg.integratedGPU.driver} __EGL_VENDOR_LIBRARY_FILENAMES=${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json")
    "${getExe pkgs.alacritty} msg create-window"
  ];
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.shell.emulator = {
    enable = mkEnableOption "Hellebore terminal emulator configuration";

    font = extra-types.font {
      size = config.hellebore.font.size;
      sizeDescription = "Set the terminal emulator font size.";
      name = "FiraMono Nerd Font";
      nameDescription = "Set the terminal emulator font family.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the terminal emulator theme.";
    };

    integratedGPU = {
      enable =
        mkEnableOption null
        // {
          description = "Enable the terminal emulator to run on the integrated GPU on a multi GPU
        setup.";
        };
      driver = mkOption {
        type = types.enum ["i965" "iris" "radeonsi"];
        default = "";
        description = "Defines the driver to run the terminal emulator on a multi GPU setup.";
      };
    };

    package = mkOption {
      type = types.package;
      default = pkgs.alacritty;
      description = "The default terminal emulator package.";
    };

    bin = mkOption {
      type = types.str;
      default = emulator-bin;
      description = "Get the terminal emulator binary.";
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = cfg.package;

      settings = {
        import = [
          (theme.alacritty.file)
        ];

        window = {
          decorations = "None";
          opacity = 0.9;
          blur = true;
        };

        font = {
          normal = {
            family = "${cfg.font.name}";
            style = "Regular";
          };

          size = cfg.font.size;
        };

        cursor = {
          style = {
            shape = "Beam";
            blinking = "On";
          };

          vi_mode_style = {
            shape = "Block";
            blinking = "On";
          };
        };
      };
    };
  };
}
