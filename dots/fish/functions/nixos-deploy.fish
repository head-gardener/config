function nixos-deploy -d "Builds and deploys a configuration to a remote NixOS host via remote sudo" -a remote_host flake
  nixos-rebuild build --target-host $remote_host --flake "$flake#$remote_host"
  NIX_SSHOPTS="-o RequestTTY=force" nixos-rebuild switch --use-remote-sudo --target-host $remote_host --flake "$flake#$remote_host"
end
