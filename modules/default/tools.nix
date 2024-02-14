{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    atop
    bat
    entr
    fd
    git
    grc
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
