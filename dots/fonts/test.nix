let pkgs = import <nixpkgs> { };
in {
  lilex = let
    pkg = pkgs.callPackage ./lilex.nix { };
    font = pkg { features = [ "cv01" "cv06" "cv02" "cv09" "ss01" "ss03" ]; };
    patcher = pkgs.callPackage ./nerdPatched.nix { };
  in patcher { inherit font; };
}
