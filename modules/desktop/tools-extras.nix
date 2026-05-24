{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    ani-cli
    awscli
    brightnessctl
    cloc
    entr
    haskellPackages.base91
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
    inputs.notesearch.packages.${stdenv.hostPlatform.system}.default
    inputs.notesearch.packages.${stdenv.hostPlatform.system}.notesearch-desktop
    minio-client
    nix-output-monitor
    nvd
    tldr
  ];
}
