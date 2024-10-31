{ alloy, lib, inputs, pkgs, config, ... }: {
  imports = [
    (inputs.self.lib.mkSecretTrigger "sing-box"
      config.age.secrets.vmess-uuid.file)
  ];

  age.secrets.vmess-uuid = { file = "${inputs.self}/secrets/vmess-uuid.age"; };

  systemd.services.sing-box.wantedBy = lib.mkForce [ ];

  services.sing-box = {
    enable = true;
    package = inputs.unstable.legacyPackages.${pkgs.system}.sing-box;
    settings = {
      log.level = "warn";

      inbounds = [{
        type = "tun";
        address = [ "172.18.0.1/30" ];
        auto_route = true;
      }];

      outbounds = lib.mkMerge [
        [
          {
            tag = "direct";
            type = "direct";
          }
          {
            tag = "vmess-out";
            type = "vmess";
            server = alloy.sing-box-out.address;
            server_port = 19555;
            alter_id = 0;
            uuid._secret = config.age.secrets.vmess-uuid.path;
          }
        ]
        (lib.mkIf (config.networking.wg-quick.interfaces != [ ]) [{
          tag = "wg";
          type = "direct";
          bind_interface = "wg0";
        }])
      ];

      route = {
        final = "vmess-out";
        auto_detect_interface = true;
        rules = lib.mkMerge [
          (lib.mkIf (config.networking.wg-quick.interfaces != [ ]) [
            {
              protocol = "dns";
              outbound = "wg";
            }
            {
              port = [ 53 ];
              outbound = "wg";
            }
          ])
          [{
            ip_is_private = true;
            outbound = "direct";
          }]
        ];
      };
    };
  };
}
