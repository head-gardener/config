{
  users.mutableUsers = false;

  users.users.root.initialHashedPassword =
    "$y$j9T$UlNL0TgigddHilkBW.16y/$ROBnTLd20FAS4uNIq8SVM2g0aVqMWQi9sbAnGoSc4SB";

  users.users.hunter = {
    isNormalUser = true;
    initialHashedPassword =
      "$6$oRQkOsmhP/Y3Kv6Z$tEDiTWye1Sqa5z.xorjpIBeHowfS01kLT3fo0F.2y831iWKfW4jAUMWM47118kpbZm62Oxw.mMPWub5FTAJKl.";
    extraGroups = [ "wheel" ];
    home = "/home/hunter";
  };
}
