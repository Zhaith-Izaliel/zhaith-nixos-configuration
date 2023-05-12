{config, pkgs, lib, ...}:

let
  customPlugins = lib.attrsets.mapAttrsToList
  (key: value: value)
  (import ./plugins.nix { inherit pkgs lib; });
  lsp-servers = lib.attrsets.mapAttrsToList
  (key: value: value)
  (import ./lsp-servers.nix { inherit pkgs lib; });
  neovim-config = (import ./config.nix { inherit pkgs lib; });
in
{
  home.file.".config/nvim/lua".source = neovim-config.lua; # Import config fetched from gitlab

  # Doc Here: https://github.com/NixOS/nixpkgs/blob/nixos-22.11/doc/languages-frameworks/vim.section.md
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''

    omnisharp_path = "${pkgs.omnisharp-roslyn}/lib/omnisharp-roslyn/OmniSharp.dll"

    '' + neovim-config.init;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      vim-sleuth
      {
        plugin = sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
      nvim-neoclip-lua
      nvim-lspconfig
      go-nvim
      telescope-nvim
      vim-illuminate
      nvim-dap
      nvim-dap-ui
      nui-nvim
      vim-kitty-navigator
      gitsigns-nvim
      nvim-colorizer-lua
      vim-nix
      go-nvim
      todo-comments-nvim
      comment-nvim
      luasnip
      nvim-web-devicons
      rust-tools-nvim
      plenary-nvim
      rest-nvim
      catppuccin-nvim
      galaxyline-nvim
      alpha-nvim
      mkdir-nvim
      yankring
      coq_nvim
      coq-artifacts
      undotree
      which-key-nvim
    ] ++ customPlugins;

    extraPackages = with pkgs; [
      graphviz
      universal-ctags
      watchman
      virtualenv
      ripgrep
      dotnet-sdk
    ] ++ lsp-servers;
  };
}
