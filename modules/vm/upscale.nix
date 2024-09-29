{ lib, config, ... }:
{
  options.virtualisation.upscale = lib.mkOption {
    default = 4;
    type = lib.types.int;
  };

  config.virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 1024 * config.virtualisation.upscale;
      cores = 1 * config.virtualisation.upscale;
    };
  };
}
