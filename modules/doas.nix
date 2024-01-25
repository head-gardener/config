users: {
  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    inherit users;
    keepEnv = true;
    persist = true;
  }];
}
