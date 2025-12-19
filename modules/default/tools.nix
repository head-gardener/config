{ pkgs, ... }:
{
  environment.pathsToLink = [ "/share/nvim/runtime" ];

  # if tool is from an input, add it to ../desktop/tools-extras.nix!

  environment.systemPackages = with pkgs; [
    atop
    bat
    beep
    below
    dig
    fd
    file
    git
    git-crypt
    grc
    jc
    jq
    just
    less
    lsof
    neovim
    nix-converter
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
