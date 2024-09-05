{
  services.xray = {
    enable = true;
    settings = {
      inbounds = [
        {
          port = 19555;
          protocol = "vmess";
          settings = {
            clients = [{
              id = "b74f08d3-f406-4d79-afa1-0917d19c2b92";
              alterId = 64;
            }];
          };
        }
      ];

      outbounds = [{ protocol = "freedom"; }];
    };
  };

  networking.firewall.allowedTCPPorts = [ 19555 ];
}
