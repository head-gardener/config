default:
  @just --list

deploy tgt:
   rsync . {{ tgt }}:/tmp/config -azv
   ssh -tt {{ tgt }} sudo nixos-rebuild switch --flake /tmp/config

stop-upgrade tgt:
   ssh -tt {{ tgt }} sudo systemctl stop nixos-upgrade.timer
