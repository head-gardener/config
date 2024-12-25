{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ pass ];
}
