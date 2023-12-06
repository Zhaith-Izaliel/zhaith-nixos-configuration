{ config, pkgs, ... }:
let
  args = "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=32M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
  ram = "-Xmx12G -Xms2G";
  server = "-jar forge-1.16.5-36.2.28.jar nogui";
in
{
  environment.systemPackages = with pkgs; [
    zulu
  ];

  systemd.services.minecraft-server = {
    enable = false;
    description = "Minecraft Server";
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.zulu}/bin/java ${ram} ${args} ${server}";
      WorkingDirectory = "/home/lilith/server/";
    };

    wantedBy = [ "multi-user.target" ];
    requires = [ "network.target" ];
  };

  firewall.allowedTCPPorts = [
    # 25565 # NOTE: for minecraft server
    # 25575 # NOTE: for minecraft RCON protocol
  ];
}
