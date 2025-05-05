{ config, pkgs, inputs, lib, ... }:
let
  opts = config.personal.term-farm;

  mkAddr = m:
    "192.168.${toString opts.net.subnet_byte}.${toString m.net.ip_byte}";

  mkSeed = { name, user-data }:
    let
      user-data-file = pkgs.writeText "${name}-user-data" ''
        #cloud-config
        ${(lib.generators.toYAML { } user-data)}
      '';
    in pkgs.stdenvNoCC.mkDerivation {
      name = "${name}-seed.iso";

      dontUnpack = true;

      buildPhase = ''
        cloud-init schema --config-file ${user-data-file} --annotate
        cloud-localds seed.iso ${user-data-file}
      '';

      installPhase = ''
        cp ./seed.iso "$out"
      '';

      nativeBuildInputs = with pkgs; [ cloud-init cloud-utils ];
    };

  mkRules = n: v: ''
     if [ "$1" = "${n}" ]; then
       if [ "$2" = "stopped" ] || [ "$2" = "reconnect" ]; then
        ${
          lib.concatStringsSep "\n" (lib.map (x: ''
            ${pkgs.iptables}/bin/iptables -D FORWARD -o ${opts.net.bridge_name} -p tcp -d ${
              mkAddr v
            } --dport ${toString x.to} -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -p tcp --dport ${
              toString x.from
            } -j DNAT --to ${mkAddr v}:${toString x.to}
          '') v.forward)
        }
       fi
       if [ "$2" = "start" ] || [ "$2" = "reconnect" ]; then
        ${
          lib.concatStringsSep "\n" (lib.map (x: ''
            ${pkgs.iptables}/bin/iptables -I FORWARD -o ${opts.net.bridge_name} -p tcp -d ${
              mkAddr v
            } --dport ${toString x.to} -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -I PREROUTING -p tcp --dport ${
              toString x.from
            } -j DNAT --to ${mkAddr v}:${toString x.to}
          '') v.forward)
        }
       fi
    fi
  '';
  mkImageCreateScript = n: v: ''
    if ! ${pkgs.libvirt}/bin/virsh vol-info "${n}.qcow2" farm > /dev/null; then
      echo "installing ${n}.qcow2 from ${v.src}..."
      ${pkgs.libvirt}/bin/virsh vol-create-as \
        farm "${n}.qcow2" \
        $(${pkgs.qemu-utils}/bin/qemu-img info ${v.src} \
          | ${pkgs.gnugrep}/bin/grep "virtual size" \
          | ${pkgs.gawk}/bin/awk '{print $3}') \
        --format qcow2
      ${pkgs.libvirt}/bin/virsh vol-upload \
        --pool farm \
        ${n}.qcow2 \
        "${v.src}"
    fi
  '';

in {
  options.personal.term-farm = {
    enable = lib.mkEnableOption "Terminal farm";
    net = {
      subnet_byte = lib.mkOption {
        default = 72;
        type = lib.types.int;
      };
      uuid = lib.mkOption { type = lib.types.str; };
      bridge_name = lib.mkOption {
        type = lib.types.str;
        default = "virbr0";
      };
    };
    pool = {
      path = lib.mkOption { type = lib.types.str; };
      uuid = lib.mkOption { type = lib.types.str; };
    };
    machines = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          uuid = lib.mkOption { type = lib.types.str; };
          resources = {
            memory = lib.mkOption { type = lib.types.attrsOf lib.types.raw; };
          };
          src = lib.mkOption { type = lib.types.package; };
          net = {
            mac = lib.mkOption { type = lib.types.str; };
            ip_byte = lib.mkOption { type = lib.types.int; };
          };
          forward = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                from = lib.mkOption { type = lib.types.int; };
                to = lib.mkOption { type = lib.types.int; };
              };
            });
          };
          cloud-config = {
            user-data = lib.mkOption { type = lib.types.attrsOf lib.types.raw; };
          };
        };
      });
    };
  };

  config = lib.mkIf opts.enable {
    system.activationScripts.term-farm-pool = {
      deps = [ "specialfs" ];
      text = ''
        mkdir -p ${opts.pool.path}
        chmod 0751 ${opts.pool.path}
      '';
    };

    system.activationScripts.term-farm-mkvols = {
      deps = [ "specialfs" ];
      text = ''
        ${lib.concatStringsSep "\n"
        (lib.mapAttrsToList mkImageCreateScript opts.machines)}
      '';
    };

    networking.nat.enable = true;

    # changing this requires manual `libvirtd-config` restart after previous rules
    virtualisation.libvirtd.hooks.qemu = {
      port-forward = pkgs.writeShellScript "term-port-forward" ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkRules opts.machines)}
      '';
    };

    virtualisation.libvirt = {
      enable = true;
      connections."qemu:///session" = {
        pools = [{
          definition = inputs.nixvirt.lib.pool.writeXML {
            name = "farm";
            uuid = opts.pool.uuid;
            type = "dir";
            target = { path = opts.pool.path; };
          };
          active = true;
        }];
        networks = [{
          definition = let
            base = inputs.nixvirt.lib.network.templates.bridge {
              name = "farm";
              uuid = opts.net.uuid;
              bridge_name = opts.net.bridge_name;
              subnet_byte = opts.net.subnet_byte;
            };

            def = base // {
              ip = base.ip // {
                dhcp = base.ip.dhcp // {
                  host = lib.mapAttrsToList (n: v: {
                    mac = v.net.mac;
                    name = n;
                    ip = mkAddr v;
                  }) opts.machines;
                };
              };
            };
          in inputs.nixvirt.lib.network.writeXML def;
          active = true;
        }];
        domains = lib.mapAttrsToList (n: v: {
          active = true;
          definition = let
            seed = mkSeed {
              name = n;
              user-data = v.cloud-config.user-data // { hostname = n; };
            };

            base = inputs.nixvirt.lib.domain.templates.linux {
              name = n;
              uuid = v.uuid;
              memory = v.resources.memory;
              storage_vol = {
                pool = "farm";
                volume = "${n}.qcow2";
              };
              install_vol = "${seed}";
              virtio_video = false;
            };

            def = base // {
              devices = base.devices // {
                console = {
                  type = "pty";
                  target = {
                    type = "serial";
                    port = 0;
                  };
                };
                serial = {
                  type = "pty";
                  target = { port = 0; };
                };
                interface = base.devices.interface // {
                  mac = { address = v.net.mac; };
                };
              };
            };
          in inputs.nixvirt.lib.domain.writeXML def;
        }) opts.machines;
      };
    };
  };
}
