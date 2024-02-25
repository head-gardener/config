{ inputs, lib, ... }:
let
  expand = p: "${inputs.self}/dots/${p}";

  mkFile = path: { source = expand path; };

  mkDir = path:
    (mkFile path) // {
      recursive = true;
    };

  isDir = path: builtins.pathExists (toString (expand path) + "/.");

  mkPath = path: if isDir path then mkDir path else mkFile path;

  mkPaths = ps: builtins.listToAttrs
    (map (p: { name = ".config/${p}"; value = mkPath p; }) ps);
in
{
  home.file = mkPaths [ "dunst" "fish" "i3" "nvim" ] //
    {
      "Pictures/11.png".source = "${inputs.self}/dots/static/11.png";
    };
}
