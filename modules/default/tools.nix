{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
    atop
    ripgrep
  ];
}
