# Unity config
{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
      unityhub
      mono
      dotnet-sdk
    ];
}