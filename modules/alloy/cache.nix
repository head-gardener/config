{ config, lib, alloy, ... }:
{
  nix = lib.mkIf (!config.services.nix-serve.enable) {
    settings = {
      substituters = [
        "https://${alloy.nix-serve.config.services.nix-serve.endpoint}/"
      ];
      trusted-public-keys = [
        alloy.nix-serve.config.services.nix-serve.pubkey
      ];
    };
  };
}
