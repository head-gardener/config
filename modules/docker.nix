{
  users.users.hunter.extraGroups = [ "docker" ];

  virtualisation = {
    docker = {
      enable = true;
    };
  };
}
