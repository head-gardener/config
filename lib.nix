lib:
with lib;
rec {
  ls = path: map (f: "${path}/${f}") (builtins.attrNames (builtins.readDir path));

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
      ] ++ extraMods;
    };

  systems = [ "x86_64-linux" ];

  importAll = path: genAttrsFromDir path import;

  forAllSystems = genAttrs systems;
}
