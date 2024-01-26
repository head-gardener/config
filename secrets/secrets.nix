let
  hunter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRFsB98uB4VjuBGAlfJx64Aclm6QHCaA0/dVUoLdn4M";
  users = [ hunter ];

  distortion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeKWUEkTCsPQaXzoUc/5JF0BecasFaiSt/f/HavHJPo";
  blueberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpw2yiiKX6H+XzVxl6rQIU5sVVI/4AePwULt8vIY5S8";
  systems = [ distortion blueberry ];
in
{
  "cache.age".publicKeys = [ hunter blueberry ];
}
