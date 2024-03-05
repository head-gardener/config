inputs: final: prev: rec {
  fishPlugins = prev.fishPlugins // fishPluginsOverlay;

  fishPluginsOverlay = {
    done = prev.fishPlugins.done.overrideAttrs (old: {
      src = inputs.unstable.legacyPackages.${final.stdenv.system}.stdenvNoCC.mkDerivation {
        inherit (old.src) rev name;
        inherit (old) src;

        installPhase = ''
          export file="./conf.d/done.fish"
          test -f $file
          substituteInPlace $file \
            --replace-fail 'if set -q KITTY_WINDOW_ID' 'if false'
          cp -r . $out
        '';
      };
    });

    abbreviation-tips = final.fishPlugins.buildFishPlugin rec {
      pname = "abbreviation-tips";
      version = "v0.7.0";

      src = final.fetchFromGitHub {
        owner = "gazorby";
        repo = "fish-abbreviation-tips";
        rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
        hash = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
      };

      meta = with final.lib; {
        description = "Helps you remember abbreviations and aliases by displaying tips when you can use them.";
        homepage = "https://github.com/Gazorby/fish-abbreviation-tips";
        license = licenses.mit;
        maintainers = with maintainers; [ ];
      };
    };

    nix-completions = final.fishPlugins.buildFishPlugin rec {
      pname = "nix-completions";
      version = "cd8a43b";

      src = final.fetchFromGitHub {
        owner = "kedonng";
        repo = "nix-completions-fish";
        rev = version;
        hash = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
      };

      meta = with final.lib; {
        description = "Fish completions for Nix.";
        homepage = "https://github.com/kidonng/nix-completions.fish";
        license = licenses.mit;
        maintainers = with maintainers; [ ];
      };
    };

    forgit-no-grc = final.fishPlugins.forgit.overrideAttrs (old: {
      src = inputs.unstable.legacyPackages.${final.stdenv.system}.stdenvNoCC.mkDerivation {
        inherit (old.src) rev name;
        inherit (old) src;

        installPhase = ''
          export file="./conf.d/forgit.plugin.fish"
          test -f $file
          substituteInPlace $file \
            --replace-fail 'grc' 'grvrc'
          cp -r . $out
        '';
      };
    });

    gitnow = final.fishPlugins.buildFishPlugin rec {
      pname = "gitnow";
      version = "2.12.0";

      src = final.fetchFromGitHub {
        owner = "joseluisq";
        repo = "gitnow";
        rev = "91bda1d0ffad2d68b21a1349f9b55a8cb5b54f35";
        hash = "sha256-PuorwmaZAeG6aNWX4sUTBIE+NMdn1iWeea3rJ2RhqRQ=";
      };

      meta = with final.lib; {
        description = "GitNow contains a command set that provides high-level operations on the top of Git";
        homepage = "https://github.com/joseluisq/gitnow";
        license = licenses.mit;
        maintainers = with maintainers; [ ];
      };
    };

    spark = final.fishPlugins.buildFishPlugin rec {
      pname = "spark";
      version = "1.2.0";

      src = final.fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "spark.fish";
        rev = "9b6ec512b2db1d379ff38e52e157b96bbc6058c3";
        hash = "sha256-AIFj7lz+QnqXGMBCfLucVwoBR3dcT0sLNPrQxA5qTuU=";
      };

      meta = with final.lib; {
        description = "Unofficial port of spark.sh with --min, --max flags and improved performance";
        homepage = "https://github.com/jorgebucaran/spark.fish";
        license = licenses.mit;
        maintainers = with maintainers; [ ];
      };
    };
  };
}
