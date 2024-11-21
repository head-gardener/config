#!/usr/bin/env bash
set -eo pipefail

function mkpassword {
  cat /dev/urandom | head -c "$1" | base91 --encode | sed "s/['\"]//"
}

function writeout {
  vault kv put -mount=services "$@"
}

function check {
  vault kv metadata get -mount=services "$@" > /dev/null || {
    echo "Path doesn't exist! Create new?"
    read -p "(y/n): " ok
    [ "$ok" == "y" ] || [ "$ok" == "Y" ]
  }
}

dry=""

if [[ "$1" == "-d" ]] || [[ "$1" == "--dry-run" ]]; then
  dry="1"
  function writeout {
    shift
    echo "$@"
  }
  function check {
    true
  }
fi

minio_changed=""

for arg in "$@"; do
  case "$arg" in
    sing-box/vmess-uuid)
      echo "Updating vmess uuid..."
      writeout "$arg" "uuid=$(cat /proc/sys/kernel/random/uuid)"
      ;;
    minio/*)
      check "$arg"
      user=$(echo "$arg" | sed -r 's|minio/(\w+)|\1|')
      echo "Updating minio creds for $user..."
      writeout "$arg" "user=$user" "pass=$(mkpassword 50 | tr ':' '-')"
      [ "$user" != "admin" ] && [ -z "$dry" ] && minio_changed=1
      ;;
    gpg/*)
      check "$arg"
      host=$(echo "$arg" | sed -r 's|gpg/(\w+)|\1|')
      echo "Updating gpg keys for $host..."
      export GNUPGHOME=$(mktemp -d)
      gpg --quiet --batch --passphrase '' --quick-gen-key "$host" default default
      writeout "$arg" "key=$(gpg --export-secret-keys | base64)"
      find $GNUPGHOME -type f -exec shred -u {} \;
      rm -rf $GNUPGHOME
      ;;
  esac
done

if [ -n "$minio_changed" ]; then
  vault kv list -mount=services > /dev/null || { source <(just login); }
  source <(just populate-env)
  tf_opts="-auto-approve";
  if [ "$(git diff $(fd -tf '.tf$' minio) | wc -l)" -ne 0 ]; then
    echo "--- Terraform configuration changed, can't auto-approve!"
    tf_opts=""
  fi
  echo $tf_opts
  terraform -chdir=minio apply "$tf_opts"
fi
