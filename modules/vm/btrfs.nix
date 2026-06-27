{ config, inputs, ... }:
let
  root = "/dev/vda";
in
{
  personal.checks.vm-btrfs = {
    modules = [
      "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
      inputs.self.nixosModules.vm-btrfs
      (
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.util-linux ];
        }
      )
    ];
    script = ''
      machine.wait_for_unit("multi-user.target")
      fs = machine.succeed("lsblk ${root} -o FSTYPE --noheadings").strip()
      assert "btrfs" in fs
    '';
  };

  boot.initrd.systemd.enable = true;

  # modules/vm/btrfs.nix requires the qemu-vm module
  # (nixpkgs/nixos/modules/virtualisation/qemu-vm.nix) to be loaded first
  virtualisation = {
    useDefaultFilesystems = false;
    rootDevice = root;
    fileSystems = {
      "/" = {
        device = config.virtualisation.rootDevice;
        fsType = "btrfs";
        autoFormat = true;
      };
    };
  };
}
