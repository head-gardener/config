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

  # make keys for dst from src's stash.
  mkKeys' = self: dst: src: {
    users.users.${dst}.openssh.authorizedKeys.keyFiles = ls "${self}/ssh/${src}";
  };

  mkKeys = self: user: mkKeys' self user user;

  mkHostModules = hostname: [
    ./hosts/${hostname}/configuration.nix
    { networking.hostName = hostname; }
    {
      _module.args.net = let
        hosts = (builtins.fromJSON (builtins.readFile "${inputs.self}/hosts.json"));
      in {
        inherit hosts;
        self = if hosts ? ${hostname} then hosts.${hostname} else {};
      };
    }
    {
      personal.facts = builtins.fromJSON
        (builtins.readFile "${inputs.self}/hosts/${hostname}/facts.json");
    }
    inputs.self.nixosModules.defaultImports
  ];

  mkDesktopModules = _: [
    inputs.self.nixosModules.desktop
    inputs.self.nixosModules.home
  ];

  # generate configuration by setting net hostname,
  # adding default module, importing shared module defs
  # and config from hosts dir.
  mkHost = system: hostname: extraMods:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = (mkHostModules hostname) ++ extraMods;
    };

  # same as mkHost but include desktop, hoe and
  # home-manager modules
  mkDesktop = system: hostname: extraMods:
    mkHost system hostname ((mkDesktopModules hostname) ++ extraMods);

  # trigger service restart on file change using sha1
  # don't use this if you can.
  # sig: string -> path -> Module
  # Example:
  # {
  #   imports = [ (mkSecretTrigger "sing-box" age.nix) ];
  # }
  mkSecretTrigger = svc: path: {
    systemd.services.${svc}.restartTriggers =
      [ (builtins.hashFile "sha1" path) ];
  };

  # forcibly override option type.
  # sig: [ String ] -> Type -> Module
  # Example:
  # {
  #   imports = [ (mkTypeOverride [ "system" "autoUpgrade" "enable" ] lib.types.int) ];
  #   config.system.autoUpgrade.enable = 5;
  # }
  mkTypeOverride = opt: type: {
    options = lib.setAttrByPath opt (lib.mkOption {
      type = type // {
        typeMerge = lib.const type;
      };
    });
  };

  addPkgs = f: { pkgs, ... }: { environment.systemPackages = f pkgs; };

  importAll = path: genAttrsFromDir path import;

  mkOverlays = imports: path: genAttrsFromDir path (p: (import p) imports);
}
