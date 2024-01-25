{
  nix = {
    settings = {
      substituters = [
        "http://cache.backyard-hg.xyz/"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "blueberry:yZO3C9X6Beti/TAEXxoJaMHeIP3jXYVWscrYyqthly8="
      ];
    };
  };
}
