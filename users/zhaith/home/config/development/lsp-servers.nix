{ lib, pkgs }:

{
  nil = pkgs.nil;

  pyright = pkgs.nodePackages.pyright;

  lua_ls = pkgs.sumneko-lua-language-server;

  rust-analyzer = pkgs.rust-analyzer;

  vscode-langsevers = pkgs.nodePackages.vscode-langservers-extracted; # CSS, HTML, JSON, ESLint

  haskell-language-server = pkgs.haskell-language-server;

  vls = pkgs.nodePackages.vls;

  ccls = pkgs.ccls;

  gopls = pkgs.gopls;

  cmake-language-server = pkgs.cmake-language-server;

  omnisharp = pkgs.omnisharp-roslyn;

  ltex = pkgs.ltex-ls;
}

