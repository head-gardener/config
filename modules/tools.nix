{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    atop
    fd
    git
    grc
    less
    neovim
    nix-tree
    rsync
    tree
    wget
  ];
}
