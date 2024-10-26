let
  hunter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRFsB98uB4VjuBGAlfJx64Aclm6QHCaA0/dVUoLdn4M";
  hunter-shears = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDY4vNmrHf1QXxSByGp+HM5aYXIlCkpkNqPeTsRiWWOh";
  hunter-ambrosia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiiSLosPqVfFJUepkajqhuNSxn3+jjTNOGjyTpKzXKv";
  users = [ hunter hunter-shears hunter-ambrosia ];
  admins = [ hunter hunter-ambrosia ];

  distortion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeKWUEkTCsPQaXzoUc/5JF0BecasFaiSt/f/HavHJPo";
  blueberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELJrb6Drbgtrg3jRcvevq8kG1N03cji3k3FkmwUFxo+";
  cherry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXFz8HHHKDZDJjy6ZKbL8ByyTKpcggl2QojdQO7jRpU";
  elderberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWCU1iKue45QhrkUE55cHDbvR0iaUWsnU7WVhdTqexh";
  shears = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYam2lNjh5m0eFyhc5Fn90J8/g/MspzIJqha/1YZsmg";
  ambrosia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwfFXaWliHP0COdjkeOG8ImQpEPGBF4Blob0uvlL0uN root@ambrosia";
  systems = [ distortion shears ambrosia ] ++ deploy;
  deploy = [ blueberry cherry elderberry ];
in
{
  "cache.age".publicKeys = [ hunter ] ++ deploy;
  "id_gh.age".publicKeys = [ hunter ] ++ systems;
  "id_conf.age".publicKeys = [ hunter ] ++ deploy;
  "minio-creds.age".publicKeys = admins ++ deploy;
  "s3-hunter.age".publicKeys = users ++ systems;
  "s3-ro.age".publicKeys = users ++ systems;
  "s3-backup.age".publicKeys = admins ++ deploy;
  "s3-torrent.age".publicKeys = [ hunter ] ++ deploy;
  "cherry-gpg.age".publicKeys = [ hunter cherry ];
  "blueberry-gpg.age".publicKeys = [ hunter blueberry ];
  "vmess-uuid.age".publicKeys = users ++ systems;
  "jenkins-slave-secret.age".publicKeys = admins ++ [ blueberry ];
}
