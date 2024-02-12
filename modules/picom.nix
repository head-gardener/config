{ pkgs, ... }:
{
  services.picom = {
    enable = true;
    package = pkgs.picom-next;
    settings = {
      shadow = true;
      shadow-radius = 7;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-exclude = [
        "name = 'Notification'"
        "class_g = 'Conky'"
      ];
      fading = true;
      fade-in-step = 0.03;
      fade-out-step = 0.03;
      inactive-opacity = 1;
      frame-opacity = 1;
      inactive-opacity-override = false;
      corner-radius = 18;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      blur-method = "dual_kawase";
      blur-strength = 5;
      blur-kern = "3x3box";
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      backend = "glx";
      vsync = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      glx-no-stencil = true;
      use-damage = true;
      log-level = "warn";
      wintypes = {
        tooltip = { fade = true; shadow = true; opacity = 0.75; focus = true; full-shadow = false; };
        dock = { shadow = false; clip-shadow-above = true; };
        dnd = { shadow = false; };
        popup_menu = { opacity = 0.8; };
        dropdown_menu = { opacity = 0.8; };
      };
    };
  };
}
