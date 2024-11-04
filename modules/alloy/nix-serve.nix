{ alloy, lib, inputs, config, ... }:
{
  options = {
    services.nix-serve.endpoint = lib.mkOption { type = lib.types.str; };
    services.nix-serve.pubkey = lib.mkOption { type = lib.types.str; };
  };

  config = {
    age.secrets.cache = {
      file = "${inputs.self}/secrets/cache.age";
    };

    personal.gc.maxAge = 40;

    services.nix-serve = {
      endpoint = "cache.backyard-hg.xyz";
      pubkey = "blueberry:yZO3C9X6Beti/TAEXxoJaMHeIP3jXYVWscrYyqthly8=";

      enable = true;
      openFirewall = alloy.nix-serve.address != alloy.nginx.address;
      secretKeyFile = config.age.secrets.cache.path;
    };
  };
}
