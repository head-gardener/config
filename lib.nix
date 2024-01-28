lib:
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

  mkKeys = self: user: {
    users.users.${user}.openssh.authorizedKeys.keyFiles = ls "${self}/ssh/${user}";
  };

  mkHost = inputs: system: hostname: extraMods:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${hostname}/configuration.nix
        { networking.hostName = hostname; }
        inputs.self.nixosModules.default
      ] ++ extraMods;
    };

  mkDesktop = inputs: system: hostname: extraMods:
    mkHost inputs system hostname ([
      inputs.self.nixosModules.desktop
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.home
    ] ++ extraMods);

  systems = [ "x86_64-linux" ];

  importAll = path: genAttrsFromDir path import;

  mkOverlays = imports: path: genAttrsFromDir path (p: (import p) imports);

  forAllSystems = genAttrs systems;
}
