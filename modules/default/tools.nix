{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    atop
    bat
    entr
    fd
    git
    grc
    inputs.agenix.packages.${pkgs.stdenv.system}.default
    jc
    jq
    less
    minio-client
    neovim
    nix-output-monitor
    nix-tree
    nushell
    ripgrep
    rsync
    tree
    wget
  ];
}
