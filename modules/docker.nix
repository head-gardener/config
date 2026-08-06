{ inputs, ... }:
{
  personal.checks.docker = {
    modules = [
      inputs.self.nixosModules.docker
    ];
    script = ''
      start_all()
      machine.wait_for_unit("docker.socket")
      machine.succeed("docker ps")
      machine.succeed("su hunter -c 'docker ps'")
    '';
  };

  users.users.hunter.extraGroups = [ "docker" ];

  virtualisation = {
    docker = {
      enable = true;
    };
  };
}
