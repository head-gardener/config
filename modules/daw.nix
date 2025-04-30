{ pkgs, inputs, ... }: {
  imports = [ inputs.musnix.nixosModules.musnix ];

  nixpkgs.allowUnfreeByName = [ "reaper" ];

  musnix.enable = true;
  users.users.hunter.extraGroups = [ "audio" ];

  environment.systemPackages = with pkgs; [ reaper guitarix ];
}
