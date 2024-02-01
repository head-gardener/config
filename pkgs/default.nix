pkgs: {
  cpanel = pkgs.callPackage ./cpanel { };

  main-menu = pkgs.callPackage ./menu { };

  lilex =
    let
      patcher = pkgs.callPackage ./fonts/nerdPatched.nix { };
      font = pkgs.callPackage ./fonts/lilex.nix {
        features = [ "cv01" "cv03" "cv06" "cv09" "cv10" "cv11" "ss01" "ss03" ];
      };
    in
    patcher { inherit font; };

  inherit (pkgs.fishPlugins) abbreviation-tips forgit-no-grc gitnow spark;
}
