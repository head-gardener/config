let
  hunter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRFsB98uB4VjuBGAlfJx64Aclm6QHCaA0/dVUoLdn4M";
  hound = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDY4vNmrHf1QXxSByGp+HM5aYXIlCkpkNqPeTsRiWWOh";
  users = [ hunter hound ];

  distortion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeKWUEkTCsPQaXzoUc/5JF0BecasFaiSt/f/HavHJPo";
  blueberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELJrb6Drbgtrg3jRcvevq8kG1N03cji3k3FkmwUFxo+";
  cherry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXFz8HHHKDZDJjy6ZKbL8ByyTKpcggl2QojdQO7jRpU";
  shears = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYam2lNjh5m0eFyhc5Fn90J8/g/MspzIJqha/1YZsmg";
  systems = [ distortion blueberry cherry shears ];
  deploy = [ blueberry cherry ];
in
{
  "cache.age".publicKeys = [ hunter ] ++ deploy;
  "id_gh.age".publicKeys = [ hunter ] ++ systems;
  "id_conf.age".publicKeys = [ hunter ] ++ deploy;
  "minio-creds.age".publicKeys = [ hunter ] ++ deploy;
  "s3-hunter.age".publicKeys = users ++ systems;
  "s3-ro.age".publicKeys = users ++ systems;
}
