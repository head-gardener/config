{ alloy, lib, config, ... }:
{
  options = {
    services.nix-serve.endpoint = lib.mkOption { type = lib.types.str; };
    services.nix-serve.pubkey = lib.mkOption { type = lib.types.str; };
  };

  config = {
    personal.va.templates.nix-serve = {
      path = "services/nix-serve/key";
      field = "key";
    };

    zramSwap.memoryPercent = lib.mkForce 200;
    personal.gc.maxAge = 90;

    services.nix-serve = {
      endpoint = "cache.backyard-hg.xyz";
      pubkey = "blueberry:yZO3C9X6Beti/TAEXxoJaMHeIP3jXYVWscrYyqthly8=";

      enable = true;
      openFirewall = alloy.nix-serve.address != alloy.nginx.address;
      secretKeyFile = config.personal.va.templates.nix-serve.destination;
    };
  };
}
