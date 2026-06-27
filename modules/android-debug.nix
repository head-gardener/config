{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.android-tools
  ];
  users.users.hunter.extraGroups = [ "adbusers" ];
}
