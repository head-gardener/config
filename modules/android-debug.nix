{ ... }: {
  programs.adb.enable = true;
  users.users.hunter.extraGroups = [ "adbusers" ];
}
