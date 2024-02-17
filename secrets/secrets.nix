let
  hunter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRFsB98uB4VjuBGAlfJx64Aclm6QHCaA0/dVUoLdn4M";
  users = [ hunter ];

  distortion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeKWUEkTCsPQaXzoUc/5JF0BecasFaiSt/f/HavHJPo";
  blueberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELJrb6Drbgtrg3jRcvevq8kG1N03cji3k3FkmwUFxo+";
  shears = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYam2lNjh5m0eFyhc5Fn90J8/g/MspzIJqha/1YZsmg";
  systems = [ distortion blueberry shears ];
in
{
  "cache.age".publicKeys = [ hunter blueberry ];
  "id_gh.age".publicKeys = [ hunter ] ++ systems;
}
