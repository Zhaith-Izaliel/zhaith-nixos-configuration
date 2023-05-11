{ pkgs, lib }:

{
  # Doc Here: https://github.com/NixOS/nixpkgs/blob/nixos-22.11/doc/languages-frameworks/vim.section.md
  neogen = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "neogen";
    version = "2.13.2";
    src = pkgs.fetchFromGitHub {
      repo = "neogen";
      owner = "danymat";
      rev = "${version}";
      sha256 = "sha256-s5yPqa4AsJF1HeD7QFZ3UeQ4Yl70K7oIviUPzL5MW/U=";
    };
  };

  pounce = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "pounce-nvim";
    version = "4509f31";
    src = pkgs.fetchFromGitHub {
      repo = "pounce.nvim";
      owner = "rlane";
      rev = "${version}";
      sha256 = "sha256-8dT4Aw4MafEv2JTfUNoZbxPFEBgUu/VXpxKLOFunipo=";
    };
  };

  overseer = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "overseer-nvim";
    version = "92e4ba8";
    src = pkgs.fetchFromGitHub {
      repo = "overseer.nvim";
      owner = "stevearc";
      rev = "${version}";
      sha256 = "sha256-L7xpgEMwFRg8qurOFibkH19Lqj+yHYQqJk4NTsCM5dg=";
    };
  };
 
}
