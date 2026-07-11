{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  home.activation.fetchNeoVimPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eo pipefail

    run --quiet "${lib.getExe config.programs.neovim.finalPackage}" --headless \
      -c '
        lua local L=require("lazy.manage.lock");
        L.update=function()end;
        require("lazy").restore({wait=true})
      ' \
      +qa

    ! ${lib.getExe pkgs.jq} -r 'to_entries[] | "\(.key)\t\(.value.commit)"' \
      ${inputs.self}/dots/nvim/lazy-lock.json \
      | while read n c; do
          a="$(${lib.getExe pkgs.gitMinimal} -C "~/.local/share/nvim/lazy/$n" rev-parse HEAD 2>/dev/null || true)"
          [ -z "$a" ] && continue
          if [ "$c" != "$a" ]; then
            echo "$n bad. expected $c, got $a"
          fi
        done \
      | grep '.'
  '';

  programs.neovim =
    let
      parsers = pkgs.runCommand "nvim-tree-sitter-parsers" { } ''
        mkdir -p $out/share/parser
        path="$out/share/parser"
        ln -s ${pkgs.tree-sitter-grammars.tree-sitter-norg}/parser      "$path/norg.so"
        ln -s ${pkgs.tree-sitter-grammars.tree-sitter-norg-meta}/parser "$path/norg_meta.so"
        ln -s ${pkgs.tree-sitter-grammars.tree-sitter-yaml}/parser      "$path/yaml.so"
      '';
    in
    {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      package = inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;
      extraPackages = with pkgs; [
        commitlint
        deadnix
        editorconfig-checker
        git
        glow
        gnumake
        gopls
        haskellPackages.hoogle
        lua-language-server
        lua51Packages.luarocks
        lua5_1
        nixd
        nixpkgs-fmt
        nodejs_latest
        proselint
        statix
      ];
      extraWrapperArgs = [
        "--suffix"
        "NVIM_TS_SITE"
        ":"
        "${parsers}/share"
      ];
      plugins = with pkgs.vimPlugins; [
        lazy-nvim
      ];
    };
}
