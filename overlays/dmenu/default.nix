inputs: final: prev:

let
  patch_url = "https://tools.suckless.org/dmenu/patches/";
in
{
  dmenu-patch-highlight = final.fetchurl {
    url = patch_url + "highlight/dmenu-highlight-4.9.diff";
    sha256 = "0q21igv9i8pwhmbnvz6xmg63vm340ygriqn4xmf2bzvdn5hkfijg";
  };

  dmenu-patch-center = final.fetchurl {
    url = patch_url + "center/dmenu-center-5.2.diff";
    sha256 = "1jck88ypx83b73i0ys7f6mqikswgd2ab5q0dfvs327gsz11jqyws";
  };

  dmenu-patch-border = final.fetchurl {
    url = patch_url + "border/dmenu-border-4.9.diff";
    sha256 = "09j9z2mx16wii3xz1cfmin42ms7ci3dig64c8sgvv7yd9nc0nv1b";
  };

  dmenu = inputs.dmenu-conf.legacyPackages.${final.system}.dmenu.override ({
    patches = with final; [
      dmenu-patch-highlight
      dmenu-patch-center
      dmenu-patch-border
    ];
    conf = ./config.h;
  });
}
