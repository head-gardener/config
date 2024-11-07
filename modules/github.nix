{ config, ... }: {
  personal.va.templates.id_gh = {
    contents = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      {{ with secret "externals/github/key" }}{{ .Data.data.key }}{{ end }}
      -----END OPENSSH PRIVATE KEY-----
    '';
    owner = "hunter";
    group = "users";
  };

  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile ${config.personal.va.templates.id_gh.destination}
      IdentitiesOnly yes
  '';
}
