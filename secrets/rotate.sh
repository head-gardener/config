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
    vmess-uuid.age)
      echo "Updating vmess uuid..."
      cat /proc/sys/kernel/random/uuid | writeout "$arg"
      echo "[[ upgrade sing-box-out"
      echo "[[ upgrade sing-box"
      ;;
    s3-backup.age)
      echo "Updating minio creds for user: backup..."
      echo -n "backup:$(mkpassword 50 | tr ':' '-')" | writeout "$arg"
      echo "[[ terraform minio"
      echo "[[ upgrade backup-s3"
      ;;
    minio-creds.age)
      echo "Updating minio admin creds..."
      echo -ne "MINIO_ROOT_USER=admin\nMINIO_ROOT_PASSWORD=$(mkpassword 50)" | writeout $arg
      echo "[[ upgrade minio"
      ;;
    gpg/*.age)
      host=$(echo "$arg" | sed -r 's|gpg/(\w+).age|\1|')
      echo "Updating gpg keys for $host..."
      export GNUPGHOME=$(mktemp -d)
      gpg --quiet --batch --passphrase '' --quick-gen-key elderberry default default
      gpg --export-secret-keys | writeout $arg
      find $GNUPGHOME -type f -exec shred -u {} \;
      rm -rf $GNUPGHOME
      echo "[[ upgrade $host"
      ;;
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
