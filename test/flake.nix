{
  description =
    "A flake containing everything that needs to be checked with nix flake check";

  inputs.parent.url = "git+file:..";

  outputs = inputs:
    with inputs;
    parent.inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        # nixosConfigurations = {
        #   inherit (parent.nixosConfigurations)
        #     ambrosia distortion blueberry elderberry;
        # };

        overlays = parent.overlays;

        nixosModules = parent.nixosModules;
      };

      systems = [ "x86_64-linux" ];

      perSystem = { inputs', ... }: {
        packages = parent.images;

        checks = inputs'.parent.checks;
      };
    };
}
