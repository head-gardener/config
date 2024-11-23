{ inputs, ... }:
{
  imports = [ inputs.self.nixosModules.rotate ];

  personal.rotate.enable = true;

  personal.rotate.paths."sing-box/vmess-uuid" = {
    onCalendar = "daily";
  };
}
