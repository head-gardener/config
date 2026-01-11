default:
  @just --list

# nixos-rebuild switch
switch:
  sudo nixos-rebuild switch --flake .

# nixos-rebuild switch from remote builder
switch-via builder:
  sudo "$( \
    nixos-rebuild build --flake . --build-host "{{ builder }}" --use-substitutes \
  )/bin/switch-to-configuration" switch

# pwd-agnostic agenix -d
get-secret secret:
  cd ./secrets && agenix -d {{ secret }}

# same as deploy, but host address and config hostname can be different
deploy-as host tgt:
  rsync --exclude-from=.gitignore --filter=':- .gitignore' \
    . {{ host }}:/tmp/config -azv
  ssh -tt {{ host }} ' \
  set -ex; \
  sys="$(nix build \
    /tmp/config#nixosConfigurations.{{ tgt }}.config.system.build.toplevel \
    --no-link --print-out-paths)"; \
  sudo "$sys/bin/switch-to-configuration" switch;'

deploy tgt:
  @just deploy-as "{{ tgt }}" "{{ tgt }}"

change-nixos-release from to:
  rg --files-with-matches {{ from }} | rg -v '^flake.lock$' | \
    xargs -I _ sh -c "echo --- _; sed -n 's/{{ from }}/{{ to }}/p' _"
  read -p "Ok? (y/n) " ok && [ "$ok" == "y" ] || exit 1
  rg --files-with-matches {{ from }} | rg -v '^flake.lock$' | \
    xargs -I _ sh -c "echo --- _; sed -i 's/{{ from }}/{{ to }}/' _"
  nix flake lock

# build system locally, send it and activate it on the remote
build-deploy tgt:
  @just build-deploy-as ${tgt} ${tgt}

build-deploy-as host tgt:
  #! /usr/bin/env bash
  set -ex
  sys="$(nix build .#nixosConfigurations.{{ tgt }}.config.system.build.toplevel \
    --no-link --print-out-paths)"
  nix copy --to ssh://{{ host }} "$sys"
  ssh -tt {{ host }} sudo "$sys/bin/switch-to-configuration" switch

# stop autoupgrade timer on the remote
stop-upgrade tgt:
  ssh -tt {{ tgt }} sudo systemctl stop nixos-upgrade.timer

# eval and pretty print an option in a config
eval-opt host opt:
  nix eval .#nixosConfigurations.{{ host }}.config.{{ opt }} --json --show-trace | jq .

# decrypt, decompress and mount a backup
receive-backup path:
  cat {{ path }} | gpg --decrypt | gunzip --stdout | btrfs receive .
