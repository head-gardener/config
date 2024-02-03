{ pkgs, ... }: {
  services.upower = {
    enable = true;
    package = pkgs.upower.override { };
  };
}
