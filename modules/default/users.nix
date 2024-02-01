{
  users.mutableUsers = false;

  users.users.root.initialHashedPassword =
    "$6$1SWrFhShtEbxYRoO$Twy9IF6IdsmbWGxbhzRvqJJHgcCMFp4q7GBJV0PSCGhlNLa2xGHPXAExGnv3GDWpWL5Bq/EIjfSFt9f/M3I8k/";

  users.users.hunter = {
    isNormalUser = true;
    initialHashedPassword =
      "$6$oRQkOsmhP/Y3Kv6Z$tEDiTWye1Sqa5z.xorjpIBeHowfS01kLT3fo0F.2y831iWKfW4jAUMWM47118kpbZm62Oxw.mMPWub5FTAJKl.";
    extraGroups = [ "wheel" ];
  };
}
