{
  services.fail2ban = {
    enable = true;
    bantime = "1h";
    maxretry = 5;
    ignoreIP = [
      "10.100.0.1/24"
    ];
    bantime-increment = {
      enable = true;
      rndtime = "8m";
    };
  };
}
