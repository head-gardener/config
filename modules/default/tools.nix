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
    grc
    jc
    jq
    just
    less
    neovim
    nix-tree
    nix-converter
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
