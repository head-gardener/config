inputs: lib:
with lib;
rec {
  # a function is functorial over its return
  fmap = f: x: (a: f (x a));

  # list all files under path
  ls = path: map (f: "${path}/${f}") (builtins.attrNames (builtins.readDir path));

  # generate attr set, where names are short names under path and values
  # are function mapped over full path's
  genAttrsFromDir = path: f:
    genAttrs
      (builtins.attrNames (builtins.readDir path))
      (p: f "${path}/${p}");

  nixpkgsFor = system: import inputs.nixpkgs {
    inherit system;
    overlays = attrValues inputs.self.overlays;
  };

  mkKeys = self: user: {
    users.users.${user}.openssh.authorizedKeys.keyFiles = ls "${self}/ssh/${user}";
  };

  mkHostModules = hostname: [
    ./hosts/${hostname}/configuration.nix
    { networking.hostName = hostname; }
    inputs.self.nixosModules.default
  ];

  mkDesktopModules = hostname: [
    inputs.self.nixosModules.desktop
    inputs.home-manager.nixosModules.home-manager
    inputs.self.nixosModules.home
  ];

  # generate configuration by setting net hostname,
  # adding default module, importing shared module defs
  # and config from hosts dir.
  mkHost = system: hostname: extraMods:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs system; };
      modules = (mkHostModules hostname) ++ extraMods;
    };

  # same as mkHost but include desktop, hoe and
  # home-manager modules
  mkDesktop = system: hostname: extraMods:
    mkHost system hostname ((mkDesktopModules hostname) ++ extraMods);

  addPkgs = f: { pkgs, ... }: { environment.systemPackages = f pkgs; };

  systems = [ "x86_64-linux" ];

  importAll = path: genAttrsFromDir path import;

  mkOverlays = imports: path: genAttrsFromDir path (p: (import p) imports);
}
