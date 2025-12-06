{ inputs, pkgs, ... }:
{
  services.nginx.virtualHosts."backyard-hg.net" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        root = "${inputs.notes.packages.${pkgs.stdenv.hostPlatform.system}.blog}/";
      };
    };
  };
}
