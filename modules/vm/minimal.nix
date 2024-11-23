{ pkgs, ... }: {
  users.users.hunter = {
    isNormalUser = true;
    password = "hunter";
    extraGroups = [ "wheel" ];
  };
  environment.systemPackages = with pkgs; [
    fastfetch
  ];
  networking.firewall.allowedTCPPorts = [ 80 3000 ];
  networking.useDHCP = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}
