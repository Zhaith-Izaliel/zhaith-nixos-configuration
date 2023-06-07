{ pkgs, lib }:

{
  # Doc Here:
  # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/doc/languages-frameworks/vim.section.md
  neogen = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "neogen";
    version = "2.13.2";
    src = pkgs.fetchFromGitHub {
      repo = "neogen";
      owner = "danymat";
      rev = version;
      sha256 = "sha256-s5yPqa4AsJF1HeD7QFZ3UeQ4Yl70K7oIviUPzL5MW/U=";
    };
  };

  pounce = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "pounce-nvim";
    version = "4509f31";
    src = pkgs.fetchFromGitHub {
      repo = "pounce.nvim";
      owner = "rlane";
      rev = version;
      sha256 = "sha256-8dT4Aw4MafEv2JTfUNoZbxPFEBgUu/VXpxKLOFunipo=";
    };
  };

  overseer = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "overseer-nvim";
    version = "92e4ba8";
    src = pkgs.fetchFromGitHub {
      repo = "overseer.nvim";
      owner = "stevearc";
      rev = version;
      sha256 = "sha256-L7xpgEMwFRg8qurOFibkH19Lqj+yHYQqJk4NTsCM5dg=";
    };
  };

  calendar-vim = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "calendar-vim";
    version = "a7e73e0";
    src = pkgs.fetchFromGitHub {
      repo = pname;
      owner = "renerocksai";
      rev = version;
      sha256 = "sha256-4XeDd+myM+wtHUsr3s1H9+GAwIjK8fAqBbFnBCeatPo=";
    };
  };

  telekasten = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "telekasten-nvim";
    version = "617469c";
    src = pkgs.fetchFromGitHub {
      repo = "telekasten.nvim";
      owner = "renerocksai";
      rev = version;
      sha256 = "sha256-vYu6uH/bY7JxRmncoFyFL0QWB5f2PiqaXCKsWfPWlTE=";
    };
  };

  telescope-bibtex = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "telescope-bibtex-nvim";
    version = "0b01f5c";
    src = pkgs.fetchFromGitHub {
      repo = "telescope-bibtex.nvim";
      owner = "nvim-telescope";
      rev = version;
      sha256 = "sha256-c1HwWQlmrtb6TYFU3pp51qpXQ8ah5oRz2htcGhMi37s=";
    };
  };

  nvim-strict = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "nvim-strict";
    version = "cba2f98";
    src = pkgs.fetchFromGitHub {
      repo = pname;
      owner = "emileferreira";
      rev = version;
      sha256 = "sha256-2gZujR8Isf6klBIjOi7tDpDn1Uu4klSnclSYJ7z3ZKM=";
    };
  };

  nabla-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "nabla-nvim";
    version = "8c143ad";
    src = pkgs.fetchFromGitHub {
      repo = "nabla.nvim";
      owner = "jbyuki";
      rev = version;
      sha256 = "sha256-YRkqxKn3J4HQZci6Im/25rg4nIVvfuKQ4bmilRQzPJ4=";
    };
  };

  coq_nvim = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "coq_nvim";
    version = "7d7cebb";
    src = pkgs.fetchFromGitHub {
      repo = pname;
      owner = "ms-jpq";
      rev = version;
      sha256 = "sha256-WW6t0OfMaemUr0nnje8XiGyeH6ROtGZtQEKQNw3Lpa4=";
    };
  };

  rust-tools-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "rust-tools-nvim";
    version = "e39cb93";
    src = pkgs.fetchFromGitHub {
      repo = "rust-tools.nvim";
      owner = "Ciel-MC";
      rev = version;
      sha256 = "sha256-U4rJLMEWH/Cls8i/EMvDxUCCoh0kEZYrK51D1luLWPw=";
    };
  };

}

