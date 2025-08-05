{ pkgs, inputs, lib, ... }: {
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.unclutter-xfixes.enable = true;

  services.conky = {
    enable = true;
    config = builtins.readFile "${inputs.self}/dots/conky/conkyrc";
  };

  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
  ];

  personal.polkit.allowUnitControl."keyd.service".groups = [ "keyd-ctl" ];
  users.groups.keyd-ctl = { };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings =
          let
            mkNums = pref: keys: lib.attrsets.mergeAttrsList
              (map
                ({ fst, snd }: { "${pref}+${snd}" = toString fst; })
                (lib.zipLists
                  (lib.range 0 100)
                  (lib.stringToCharacters keys)));
          in
          {
            main = {
              capslock = "overload(meta, esc)";
              # "macro(aa)" = "C-a";
              space = "overload(control, space)";
              tab = "overload(alt, tab)";
              z = "overload(alt, z)";
              m = "overloadt(meta, m, 300)";
            } // mkNums "n" "asdfghjkl;";
          };
      };
    };
  };

  services.libinput.enable = true;

  services.xserver = {
    enable = true;

    xkb = {
      layout = "us,ru";
      options = "eurosign:e,grp:toggle";
    };

    desktopManager = {
      xterm.enable = false;
    };
  };
}
