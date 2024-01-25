{
  fileSystems."/drive-d" = {
    device = "/dev/disk/by-uuid/1254FD7854FD5F43";
    fsType = "ntfs3";
    options = [ "uid=1000" "gid=1000" "umask=0022" ];
    neededForBoot = false;
  };

  services.nginx.virtualHosts."93.125.3.204" = {
    locations = {
      "/" = {
        root = "/drive-d/";
        extraConfig = ''
          autoindex on;
          limit_req zone=common;
        '';
        basicAuth = { dina = "17133678592"; };
      };
    };
  };
}
