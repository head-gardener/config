#!/usr/bin/env bash
set -eo pipefail

function mkpassword {
  cat /dev/urandom | head -c "$1" | base91 --encode | sed "s/['\"]//"
}

function writeout {
  EDITOR=cat agenix -e "$1"
}

if [[ "$1" == "-d" ]] || [[ "$1" == "--dry-run" ]]; then
  dry="1"
  function writeout {
    cat
    echo ""
  }
fi

for arg in "$@"; do
  case "$arg" in
    wg/*.age)
      host=$(echo "$arg" | sed -r 's|wg/(\w+).age|\1|')
      echo "Updating wirguard keys for $host..."
      wg genkey | tr -d '\n' | writeout $arg
      hosts=$(jq ".$host.publicKey = \"$(agenix -d "wg/$host.age" | wg pubkey)\"" ../hosts.json)
      [ "$dry" != "1" ] && echo "$hosts" > ../hosts.json
      [ "$dry" == "1" ] && echo "$hosts"
      echo "[[ upgrade $host"
      echo "[[ upgrade wireguard-server"
      ;;
  esac
done
