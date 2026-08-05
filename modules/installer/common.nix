{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
let
  cfg = config.personal.installer;
in
{
  imports = [
    "${modulesPath}/profiles/image-based-appliance.nix"
  ];

  users.users.root.initialPassword = "root";
  services.getty.autologinUser = "root";

  i18n.glibcLocales = null;

  systemd.settings.Manager.ShowStatus = "yes";

  systemd.services.installer = {
    description = "Auto-install disk image";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.curl
      pkgs.zstd
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
    script = ''
      set -euxo pipefail

      image_url="''${image_url:-}"
      target_disk="''${target_disk:-}"

      if [ -z "$image_url" ]; then
        echo "No image url provided, skipping auto-install"
        exit 1
      fi

      if \
        ( [ -z "$target_disk" ] && echo -n "No target disk given. " ) || \
        ( [ "$target_disk" == "auto" ] && echo -n "Target disk set to 'auto'. " ); then
        target_disk="$(
          lsblk --filter "type=='disk'" --noheadings -o name -x size -p \
          | head -1)"
        echo "Detected target disk to be $target_disk"
      fi

      echo "Waiting for network connectivity..."
      for i in $(seq 1 30); do
        if curl -fsSL --head --connect-timeout 2 -I "$image_url"; then
          echo "Network is ready."
          break
        fi
        echo "  waiting... ($i/30)"
        sleep 2
      done

      decompress=zstd
      case "$image_url" in
        *.zst) decompress="zstd -d" ;;
        *) decompress=cat ;;
      esac

      touch /run/installer-started

      echo "Downloading and writing disk image from $image_url to $target_disk..."
      curl -fsSL --retry 15 --retry-delay 5 --retry-all-errors "$image_url" \
        | $decompress \
        | dd of="$target_disk" bs=4M conv=fsync status=progress

      echo "Installation complete! Rebooting..."
      sync
      sleep 3
      reboot -f
    '';
  };

  systemd.services.watchdog = lib.mkIf (cfg.watchdogSeconds > 0) {
    description = "Reset the machine if the installer never starts";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "infinity";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
    script = ''
      sleep ${toString cfg.watchdogSeconds}
      if [ -e /run/installer-started ]; then
        echo "Installer is writing to disk, standing down."
        exit 0
      fi
      echo "Installer never started, resetting."
      echo b > /proc/sysrq-trigger
    '';
  };
}
