{ config, pkgs, lib, ... }:
let opts = config.services.wg-tracer;
in {
  options.services.wg-tracer = {
    promtailUser = lib.mkOption {
      default = "promtail";
      type = lib.types.str;
    };
    wgImplementation = lib.mkOption {
      default = "wg-quick";
      type = lib.types.str;
    };
    bufferPath = lib.mkOption {
      default = "/run/wg0-dump";
      type = lib.types.str;
    };
    interface = lib.mkOption {
      default = "wg0";
      type = lib.types.str;
    };
  };

  config = {
    assertions = [{
      assertion = (config.networking.wg-quick.interfaces != [ ]
        || config.networking.wireguard.interfaces != [ ])
        && config.services.promtail.enable;
      message =
        "wg-quick or wireguard, and promtail need to be running for wg-tracer.";
    }];

    systemd.services."${opts.interface}-dump" = {
      description = "tcpdump from ${opts.interface}";
      after = [ "wg-quick-${opts.interface}.service" ];
      before = [ "promtail.service" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${lib.getExe pkgs.tcpdump} -nqi ${opts.interface} > ${opts.bufferPath}
      '';
      preStart = ''
        # mkfifo -m 600 ${opts.bufferPath}
        touch ${opts.bufferPath}
        chmod 600 ${opts.bufferPath}
        ${pkgs.acl.bin}/bin/setfacl -m u:${opts.promtailUser}:r ${opts.bufferPath}
      '';
      postStop = ''
        rm ${opts.bufferPath}
      '';
      serviceConfig.RuntimeMaxSex = "1h";
    };

    services.promtail.configuration.scrape_configs = [{
      job_name = "wireguard";
      static_configs = [{
        labels = {
          job = opts.interface;
          host = config.networking.hostName;
          __path__ = opts.bufferPath;
        };
      }];
    }];
  };
}
