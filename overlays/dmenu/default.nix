_: final: prev:

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
    url = patch_url + "/border/dmenu-border-20230512-0fe460d.diff";
    sha256 = "12lahhbp9nwkzlbv4nbmvwb90sgnci93gspzq1cyspj21pd7azw5";
  };

  dmenu = prev.dmenu.override {
    patches = with final; [
      dmenu-patch-highlight
      dmenu-patch-center
      dmenu-patch-border
    ];
    conf = ./config.h;
  };
}
