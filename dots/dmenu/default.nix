{ pkgs }:

let patch_url = "https://tools.suckless.org/dmenu/patches/";
in pkgs.dmenu.overrideAttrs (old: {
  patches = [
    (builtins.fetchurl {
      url = patch_url + "highlight/dmenu-highlight-4.9.diff";
      sha256 = "0q21igv9i8pwhmbnvz6xmg63vm340ygriqn4xmf2bzvdn5hkfijg";
    })
    (builtins.fetchurl {
      url = patch_url + "center/dmenu-center-5.2.diff";
      sha256 = "1jck88ypx83b73i0ys7f6mqikswgd2ab5q0dfvs327gsz11jqyws";
    })
    (builtins.fetchurl {
      url = patch_url + "border/dmenu-border-4.9.diff";
      sha256 = "09j9z2mx16wii3xz1cfmin42ms7ci3dig64c8sgvv7yd9nc0nv1b";
    })
  ];

  postPatch = ''
    cp ${./config.h} config.h -v
    ${old.postPatch}
  '';
})
