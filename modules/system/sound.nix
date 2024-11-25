{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    mkPackageOption
    optionalAttrs
    mkMerge
    optionals
    getExe
    concatStringsSep
    ;

  cfg = config.hellebore.sound;
  toPeriod = quantum: "${toString quantum}/${toString cfg.lowLatency.rate}";
  finalPackage = pkgs.pipewire.override (optionalAttrs cfg.soundSharing.enable {zeroconfSupport = true;});
  isSoundSharingSender = builtins.any (item: item == cfg.soundSharing.mode) ["sender" "both"];
  screamExec = pkgs.writeScriptBin "scream-receiver" ''
    ${getExe cfg.soundSharing.scream.package} -i ${cfg.soundSharing.scream.networkInterface} ${concatStringsSep " " cfg.soundSharing.scream.extraArgs}
  '';
in {
  options.hellebore.sound = {
    enable = mkEnableOption "Hellebore sound configuration";

    package = mkPackageOption pkgs "pipewire" {};

    bluetoothEnhancements = mkEnableOption "the mSBC and SBC-XQ bluetooth codec in Wireplumber.";

    lowLatency = {
      enable = mkEnableOption "PipeWire low-latency configuration";

      rate = mkOption {
        default = 48000;
        type = types.ints.unsigned;
        description = "Defines the clock rate for the audio period in PipeWire.";
      };

      quantum = mkOption {
        default = 32;
        type = types.ints.unsigned;
        description = "Defines the quantum size for the audio period in
        PipeWire.";
      };

      minQuantum = mkOption {
        default = 32;
        type = types.ints.unsigned;
        description = "Defines the minimum quantum size for the audio period
          in PipeWire.";
      };

      maxQuantum = mkOption {
        default = 32;
        type = types.ints.unsigned;
        description = "Defines the maximum quantum size for the audio period in
        PipeWire.";
      };
    };

    soundSharing = {
      enable = mkEnableOption "sound sharing between Linux computers over the network using pipewire-pulseaudio";

      mode = mkOption {
        type = types.enum ["receiver" "sender" "both"];
        default = "both";
        description = "Defines if the current machine is a receiver, a sender, or both.";
      };

      senderAddress = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The local IP address of the sender. It is only used when your machine is sending sound to the network.";
      };

      scream = {
        enable = mkEnableOption "Scream, audio receiver for sharing sound between Linux and Windows";

        package = mkPackageOption pkgs "scream" {};

        networkInterface = mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "The network interface on which Scream checks for";
        };

        extraArgs = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = [];
          description = "Extra arguments to append to Scream when it is running.";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        package = finalPackage;

        wireplumber = {
          enable = true;
        };

        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      hardware = {
        # IMPORTANT: disable pulseaudio when using pipewire
        pulseaudio.enable = false;
      };
    }

    (mkIf cfg.bluetoothEnhancements {
      services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
        };
      };
    })

    (mkIf cfg.soundSharing.enable {
      services.avahi = {
        enable = true;
        openFirewall = true;

        publish = mkIf isSoundSharingSender {
          enable = true;
          userServices = true;
        };
      };

      services.pipewire.extraConfig.pipewire-pulse."50-network-sharing" = {
        pulse.cmd =
          [
            {
              cmd = "load-module";
              args = "module-zeroconf-discover";
            }
          ]
          ++ optionals isSoundSharingSender [
            {
              cmd = "load-modules";
              args = "module-native-protocol-tcp listen=${cfg.soundSharing.senderAddress}";
            }
            {
              cmd = "load-modules";
              args = "module-zeroconf-publish";
            }
          ];
      };
    })

    (mkIf (cfg.soundSharing.enable && cfg.soundSharing.scream.enable) {
      users.users.scream = {
        isSystemUser = true;
        group = "scream";
      };

      users.groups.scream = {};

      systemd.services.scream-receiver = {
        description = "Receiver for Scream, a virtual network sound card for Microsoft Windows.";
        wantedBy = ["multi-user.target"];
        after = ["network-online.target" "sound.target"];
        requires = ["network-online.target" "sound.target"];
        restartTriggers = [
          screamExec
        ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = screamExec;
        };
      };
    })

    (mkIf cfg.lowLatency.enable {
      services.pipewire.extraConfig.pipewire."92-low-latency" = {
        context = {
          properties = {
            default.clock.rate = cfg.lowLatency.rate;
            default.clock.quantum = cfg.lowLatency.quantum;
            default.clock.min-quantum = cfg.lowLatency.minQuantum;
            default.clock.max-quantum = cfg.lowLatency.maxQuantum;
          };
          modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.req = toPeriod cfg.lowLatency.minQuantum;
                pulse.default.req = toPeriod cfg.lowLatency.quantum;
                pulse.max.req = toPeriod cfg.lowLatency.maxQuantum;
                pulse.min.quantum = toPeriod cfg.lowLatency.minQuantum;
                pulse.max.quantum = toPeriod cfg.lowLatency.maxQuantum;
              };
            }
          ];
        };
        stream.properties = {
          node.latency = toPeriod cfg.lowLatency.quantum;
          resample.quality = 1;
        };
      };
    })
  ]);
}
