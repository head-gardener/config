let
  hunter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRFsB98uB4VjuBGAlfJx64Aclm6QHCaA0/dVUoLdn4M";
  hunter-shears = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDY4vNmrHf1QXxSByGp+HM5aYXIlCkpkNqPeTsRiWWOh";
  hunter-ambrosia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiiSLosPqVfFJUepkajqhuNSxn3+jjTNOGjyTpKzXKv";
  users = [ hunter hunter-shears hunter-ambrosia ];
  admins = [ hunter hunter-ambrosia ];

  distortion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeKWUEkTCsPQaXzoUc/5JF0BecasFaiSt/f/HavHJPo";
  blueberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELJrb6Drbgtrg3jRcvevq8kG1N03cji3k3FkmwUFxo+";
  cherry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXFz8HHHKDZDJjy6ZKbL8ByyTKpcggl2QojdQO7jRpU";
  damson = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBjwUUJuOVNjXaOMO88p02Wa4ScGlLrlgPiH7hVYaOMs";
  elderberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWCU1iKue45QhrkUE55cHDbvR0iaUWsnU7WVhdTqexh";
  shears = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYam2lNjh5m0eFyhc5Fn90J8/g/MspzIJqha/1YZsmg";
  ambrosia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwfFXaWliHP0COdjkeOG8ImQpEPGBF4Blob0uvlL0uN root@ambrosia";
  systems = [ distortion shears ambrosia ] ++ deploy;
  deploy = [ blueberry cherry elderberry ];
in
{
  "wg/ambrosia.age".publicKeys = admins ++ [ ambrosia ];
  "wg/distortion.age".publicKeys = admins ++ [ distortion ];
  "wg/damson.age".publicKeys = admins ++ [ damson ];
  "wg/blueberry.age".publicKeys = admins ++ [ blueberry ];
  "wg/elderberry.age".publicKeys = admins ++ [ elderberry ];
}
