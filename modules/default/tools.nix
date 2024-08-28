{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    atop
    bat
    below
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
    s3fs
    sd
    tcpdump
    tree
    unzip
    wget
    zip
  ];
}
