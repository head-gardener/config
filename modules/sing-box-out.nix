{ inputs, config, pkgs, ... }:
{
  imports = [
    (inputs.self.lib.mkSecretTrigger "sing-box"
      config.age.secrets.vmess-uuid.file)
  ];

  age.secrets.vmess-uuid = {
    file = "${inputs.self}/secrets/vmess-uuid.age";
  };

  services.sing-box = {
    enable = true;
    package = inputs.unstable.legacyPackages.${pkgs.system}.sing-box;
    settings = {
      log.level = "warn";
      inbounds = [
        {
          listen = "::";
          listen_port = 19555;
          type = "vmess";
          tag = "vmess-in";
          users = [{
            name = "default";
            uuid._secret = config.age.secrets.vmess-uuid.path;
            alterID = 0;
          }];
          tls = {
            enabled = false;
          };
        }
      ];
      outbounds = [
        { tag = "direct"; type = "direct"; }
      ];
      route = {
        final = "direct";
        auto_detect_interface = true;
        rules = [ ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 19555 ];
}
