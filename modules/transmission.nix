{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [ transmission-gtk ];

  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      download-dir = "${config.services.transmission.home}/Downloads";
    };
  };
}
