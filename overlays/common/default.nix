inputs: final: prev: {
  ls_colors = final.runCommand "LS_COLORS" { } ''
    ${final.lib.getExe final.vivid} generate catppuccin-mocha > $out
  '';

  inherit (inputs.unstable.legacyPackages.${final.stdenv.hostPlatform.system})
    nerd-font-patcher
    nixd;
}
