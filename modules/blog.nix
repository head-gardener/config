{ inputs, pkgs, ... }:
{
  services.nginx.virtualHosts."backyard-hg.xyz" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        root = "${inputs.notes.packages.${pkgs.system}.blog-render}/";
      };
    };
  };
}
