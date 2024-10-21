{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    atop
    bat
    beep
    below
    fd
    git
    grc
    jc
    jq
    just
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
