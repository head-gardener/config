{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    atop
    bat
    entr
    fd
    git
    grc
    jq
    less
    neovim
    nix-tree
    rsync
    tree
    wget
  ];
}
