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
    neovim
    nix-tree
    nushell
    ripgrep
    rsync
    tree
    wget
  ];
}
