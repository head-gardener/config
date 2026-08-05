{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  osRelease = pkgs.runCommand "nextroot-os-release" { } ''
    cp -L ${config.system.build.toplevel}/etc/os-release $out
  '';
in
{
  boot.isContainer = true;

  console.enable = true;
  systemd.services.console-getty.enable = false;

  networking.resolvconf.enable = false;
  networking.useHostResolvConf = false;
  networking.firewall.enable = false;

  systemd.services.installer.serviceConfig.EnvironmentFile = lib.mkBefore "-/etc/installer.env";
  systemd.services.installer.script = lib.mkBefore ''
    image_url="''${IMAGE_URL:-}"
    target_disk="''${TARGET_DISK:-}"
  '';

  system.build.tarball = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
    fileName = "nextroot";
    extraArgs = "--owner=0";

    compressCommand = "zstd -T0 -19";
    compressionExtension = ".zst";
    extraInputs = [ pkgs.zstd ];

    contents = [
      {
        source = pkgs.writeShellScript "nextroot-init" ''
          exec ${config.system.build.toplevel}/init
        '';
        target = "/sbin/init";
      }
      {
        source = osRelease;
        target = "/etc/os-release";
      }
    ];
  };

  system.build.squashfsStore = pkgs.callPackage "${modulesPath}/../lib/make-squashfs.nix" {
    fileName = "nextroot-store";
    storeContents = [ config.system.build.toplevel ];
    comp = "zstd -Xcompression-level 19";
    hydraBuildProduct = true;
  };
}
