{ config, lib, pkgs, ... }:

let
  kitten = import ./kitten.nix { inherit pkgs lib; };
in
{
  home.file = {
    "${config.xdg.configHome}/kitty/pass_keys.py".source = "${kitten.vim-kitty-navigator}/pass_keys.py";
    "${config.xdg.configHome}/kitty/neighboring_window.py".source = "${kitten.vim-kitty-navigator}/neighboring_window.py";
    "${config.xdg.configHome}/kitty/tab_bar.py".source = lib.cleanSource ./tab_bar.py;
  };
}

