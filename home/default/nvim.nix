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

      # vscode-style snippet packages pulled from GitHub. Each must ship a
      # package.json (at the repo root) with `contributes.snippets` mapping
      # languages to json/jsonc files.
      vscodeSnippetPkgs = with pkgs; [
        (fetchFromGitHub {
          owner = "hnkuanx";
          repo = "vscode-golang-snippets";
          rev = "fd82acb9b9f4cdfa2482bd9364426287f1af312e";
          sha256 = "sha256-RaLJmBUl+4CkFQhJQOmaK2//DOrIE42/CRVO8nrCLmM=";
          sparseCheckout = [
            "package.json"
            "snippets"
          ];
        })
        (fetchFromGitHub {
          owner = "ylcnfrht";
          repo = "vscode-python-snippet-pack";
          rev = "7fa16e40449c3edac77e9fabf66ae53658949ee6";
          sha256 = "sha256-dkmTQ81zvc9oFf4dUmqc/JcKVOl7cn/nfIS/d7nHz2I=";
          sparseCheckout = [
            "package.json"
            "snippets"
          ];
        })
        (fetchFromGitHub {
          owner = "stephrobert";
          repo = "ansible-snippets";
          rev = "1cedf8adc8f68771737ee47129325754aaab1233";
          sha256 = "sha256-Ngv2nVvSEcfyf3faf2mPU1rPbueIU0rWGaK9UxzlVJY=";
          sparseCheckout = [
            "package.json"
            "snippets"
          ];
        })
      ];
      vscodeSnippetPaths = lib.concatStringsSep ":" vscodeSnippetPkgs;
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
      ]
      ++ lib.optionals (vscodeSnippetPaths != "") [
        "--set"
        "NVIM_VSCODE_SNIPPET_PATHS"
        vscodeSnippetPaths
      ];
      plugins = with pkgs.vimPlugins; [
        lazy-nvim
      ];
    };
}
