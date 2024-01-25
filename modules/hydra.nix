{
  networking.firewall.allowedTCPPorts = [ 3000 ];
  services.hydra = {
    enable = true;
    hydraURL = "http://hydra:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };
  services.postgresql.enable = true;
}
