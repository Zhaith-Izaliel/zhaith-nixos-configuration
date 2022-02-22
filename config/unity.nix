# Unity config
{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
      unity3d
      unityhub
      mono
      dotnet-sdk
    ];
}