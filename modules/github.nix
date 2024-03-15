{ config, inputs, ... }: {
  age.secrets.id_gh = {
    file = "${inputs.self}/secrets/id_gh.age";
    owner = "hunter";
    group = "users";
  };

  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile ${config.age.secrets.id_gh.path}
      IdentitiesOnly yes
  '';
}
