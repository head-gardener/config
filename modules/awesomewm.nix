{ pkgs, config, lib, ... }:
let
  luaversion = config.services.xserver.windowManager.awesome.package.lua.luaversion;
  awesomex = pkgs.stdenv.mkDerivation {
    pname = "awesomex";
    version = "unstable-2025-05-24";
    src = pkgs.fetchFromGitHub {
      owner = "mousebyte";
      repo = "awesomex";
      rev = "6701809246f67975c74e1236b7389bbff0e57f7e";
      sha256 = "sha256-dnWnGBbGCjyc9JT4enijJden5qNcLPkd1MjiUYd8o2M=";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/lua/${luaversion}/awesomex
      cp *.lua $out/share/lua/${luaversion}/awesomex/
      cp -r widget $out/share/lua/${luaversion}/awesomex/
      cp -r client $out/share/lua/${luaversion}/awesomex/
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    awesome
    i3lock-color
    i3status
  ];

  environment.pathsToLink = [ "/share/awesome" ];

  services.xserver = {
    enable = true;

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        awesome-wm-widgets
      ] ++ [ awesomex ];
    };
  };
}
