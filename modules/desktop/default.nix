{ inputs, lib, ... }:
{
  imports =
    (builtins.filter (x: !(lib.hasSuffix "default.nix" x))
      (inputs.self.lib.ls "${inputs.self}/modules/desktop"))
    ++ [
      { nixpkgs.overlays = [ inputs.neovim-nightly.overlay ]; }
    ];
}
