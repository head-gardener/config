lib:
with lib;
rec {
  ls = path: map (f: "${path}/${f}") (builtins.attrNames (builtins.readDir path));

  mkKeys = keys: user: {
    users.users.${user}.openssh.authorizedKeys.keyFiles = ls "${keys}/${user}";
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
}
