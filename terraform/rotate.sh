#!/usr/bin/env bash
set -eo pipefail

function mkpassword {
  cat /dev/urandom | head -c "$1" | base91 --encode | sed "s/['\"]//"
}

function writeout {
  vault kv put -mount=services "$@"
}

if [[ "$1" == "-d" ]] || [[ "$1" == "--dry-run" ]]; then
  dry="1"
  function writeout {
    shift
    echo "$@"
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
      user=$(echo "$arg" | sed -r 's|minio/(\w+)|\1|')
      echo "Updating minio creds for $user..."
      writeout "$arg" "user=$user" "pass=$(mkpassword 50 | tr ':' '-')"
      minio_changed=1
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
