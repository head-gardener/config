{ pkgs, ... }:
{

  programs.newsboat = {
    enable = true;
    extraConfig = ''
      notify-program "${pkgs.dunst}/bin/dunstify -a 'Newsboat' -u low '%t' '%u'"
    '';
    urls = [
      {
        title = "Ian Henry";
        url = "https://ianthehenry.com/feed.xml";
      }
      {
        title = "Willghatch";
        url = "http://www.willghatch.net/blog/feeds/all.rss.xml";
      }
      {
        title = "tweag nix";
        url = "https://www.tweag.io/rss-nix.xml";
      }
      {
        title = "tweag engineering";
        url = "https://www.tweag.io/rss.xml";
      }
      {
        title = "monday morning haskell";
        url = "https://mmhaskell.com/blog?format=rss";
      }
      {
        title = "Haskell Weekly";
        url = "https://haskellweekly.news/newsletter.atom";
      }
      {
        title = "planet haskell";
        url = "https://planet.haskell.org/rss20.xml";
      }
      {
        title = "Lilex";
        url = "https://github.com/mishamyrt/Lilex/tags.atom";
      }
      {
        title = "Conal Elliott's blog";
        url = "http://conal.net/blog/feed";
      }
      {
        title = "NixOS Weekly";
        url = "https://weekly.nixos.org/feeds/all.rss.xml";
      }
      {
        title = "Reasonably Polymorphic (Sandy Maguire)";
        url = "https://reasonablypolymorphic.com/atom.xml";
      }
    ];
  };

}
