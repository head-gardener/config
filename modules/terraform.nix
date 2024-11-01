{ pkgs, ... }:
{
  nixpkgs.allowUnfreeByName = [ "terraform" ];
  environment.systemPackages = [ pkgs.terraform ];
  environment.variables."TF_CLI_CONFIG_FILE" = pkgs.writeText "conf.tfrc" ''
    provider_installation {
      network_mirror {
        url = "https://tfmirror.dev/"
      }
    }
  '';
}
