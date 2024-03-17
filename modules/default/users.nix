{
  users.mutableUsers = false;

  users.users.root.initialHashedPassword =
    "$y$j9T$2qJiPOJ3kKfwkcp.iFaxM1$H8.ADznGEeJ4l2K1aQHz8URxkPNQuRB40r5t0EQ5eK.";

  users.users.hunter = {
    isNormalUser = true;
    initialHashedPassword =
      "$6$oRQkOsmhP/Y3Kv6Z$tEDiTWye1Sqa5z.xorjpIBeHowfS01kLT3fo0F.2y831iWKfW4jAUMWM47118kpbZm62Oxw.mMPWub5FTAJKl.";
    extraGroups = [ "wheel" ];
    home = "/home/hunter";
  };
}
