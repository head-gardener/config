{ inputs, pkgs, lib, ... }:
{
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "opencode-wrapped";
      paths = [ inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/opencode \
          --prefix PATH : ${pkgs.lib.makeBinPath [
            pkgs.uv
            pkgs.nodejs
          ]} \
          --set SUDO_ASKPASS '${lib.getExe pkgs.kdePackages.ksshaskpass}'
      '';
    })
  ];
}
