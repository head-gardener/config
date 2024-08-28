{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    ani-cli
    awscli
    cloc
    entr
    haskellPackages.base91
    inputs.agenix.packages.${system}.default
    minio-client
    nix-output-monitor
    nvd
    tldr
  ];
}
