inputs: final: prev: {
  ls_colors = final.runCommand "LS_COLORS" { } ''
    ${final.lib.getExe final.vivid} generate catppuccin-mocha > $out
  '';

  inherit (inputs.unstable.legacyPackages.${final.system})
    neovim
    neovim-unwrapped
    nerd-font-patcher
    nixd;
}
