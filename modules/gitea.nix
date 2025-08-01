{ alloy, config, ... }:
{

  personal.mappings."gitea.local".nginx = {
    enable = true;
    port = config.services.gitea.settings.server.HTTP_PORT;
  };

 services.gitea = {
    enable = true;
    lfs.enable = true;
    settings = {
      server = {
        START_SSH_SERVER = true;
        SSH_PORT = 2222;
        PROTOCOL = "http";
        HTTP_PORT = 7090;
        HTTP_ADDR = "gitea.local";
        ROOT_URL = "http://gitea.local/";
      };
      log.LEVEL = "Warn";
      session.COOKIE_SECURE = false;
      service.DISABLE_REGISTRATION = false;
      security = {
        LOGIN_REMEMBER_DAYS = 31;
        PASSWORD_HASH_ALGO = "scrypt";
        MIN_PASSWORD_LENGTH = 10;
      };
      other = {
        SHOW_FOOTER_VERSION = false;
      };
    };
    database = {
      type = "sqlite3";
      createDatabase = true;
    };
  };
}
