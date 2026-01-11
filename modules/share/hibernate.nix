{ config, lib, ... }:
let
  cfg = config.personal.hibernate;
  facts = config.personal.facts.facts;
in
{
  options.personal.hibernate = {
    enable = lib.mkEnableOption "hibernate";

    file = lib.mkOption {
      type = lib.types.str;
      description = "Swapfile to hibernate to.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        personal.facts.enable = true;
      }
      (lib.mkIf (facts != null) (
        let
          swapfile = lib.findFirst (
            x: x.path == cfg.file
          ) (throw "Facts don't contain swapfile ${cfg.file}!") facts.swapfiles;
        in
        {
          boot = {
            kernelParams = [
              "resume_offset=${swapfile.offset}"
            ];

            resumeDevice = "${swapfile.device}";
          };

          # vm's won't boot if resumeDevice is set.
          virtualisation.vmVariant = {
            boot.resumeDevice = lib.mkForce "";
          };

          virtualisation.vmVariantWithBootLoader = {
            boot.resumeDevice = lib.mkForce "";
          };
        }
      ))
    ]
  );
}
