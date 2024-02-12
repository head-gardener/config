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
    nushell
    ripgrep
    rsync
    tree
    wget
  ];
}
