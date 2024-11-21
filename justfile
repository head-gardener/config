default:
  @just --list

# nixos-rebuild switch
switch:
  sudo nixos-rebuild switch --flake .

# pwd-agnostic agenix -d
get-secret secret:
  cd ./secrets && agenix -d {{ secret }}

# send sources to the target, build and activate remotely
deploy tgt:
  rsync --exclude-from=.gitignore --filter=':- .gitignore' \
    . {{ tgt }}:/tmp/config -azv
  ssh -tt {{ tgt }} ' \
  sys="$(nix build \
    /tmp/config#nixosConfigurations.{{ tgt }}.config.system.build.toplevel \
    --no-link --print-out-paths)"; \
  sudo "$sys/bin/switch-to-configuration" switch;'

change-nixos-release from to:
  rg --files-with-matches {{ from }} | rg -v '^flake.lock$' | \
    xargs -I _ sh -c "echo --- _; sed -n 's/{{ from }}/{{ to }}/p' _"
  read -p "Ok? (y/n) " ok && [ "$ok" == "y" ] || exit 1
  rg --files-with-matches {{ from }} | rg -v '^flake.lock$' | \
    xargs -I _ sh -c "echo --- _; sed -i 's/{{ from }}/{{ to }}/' _"
  nix flake lock

# build system locally, send it and activate it on the remote
build-deploy tgt:
  #! /usr/bin/env bash
  set -ex
  sys="$(nix build .#nixosConfigurations.{{ tgt }}.config.system.build.toplevel \
    --no-link --print-out-paths)"
  nix copy --to ssh://{{ tgt }} "$sys"
  ssh -tt {{ tgt }} sudo "$sys/bin/switch-to-configuration" switch

# stop autoupgrade timer on the remote
stop-upgrade tgt:
  ssh -tt {{ tgt }} sudo systemctl stop nixos-upgrade.timer

# eval and pretty print an option in a config
eval-opt host opt:
  nix eval .#nixosConfigurations.{{ host }}.config.{{ opt }} --json --show-trace | jq .

# decrypt, decompress and mount a backup
receive-backup path:
  cat {{ path }} | gpg --decrypt | gunzip --stdout | btrfs receive .
