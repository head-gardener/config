#!/usr/bin/env bash

function mkpassword {
  cat /dev/urandom | head -c "$1" | base91 --encode | sed "s/['\"]//"
}

function writeout {
  EDITOR=cat agenix -e "$1"
}

if [[ "$1" == "-d" ]] || [[ "$1" == "--dry-run" ]]; then
  function writeout {
    cat
    echo ""
  }
fi

for arg in "$@"; do
  case "$arg" in
    vmess-uuid.age)
      echo Updating vmess uuid...
      cat /proc/sys/kernel/random/uuid | writeout "$arg"
      echo "[[ upgrade sing-box-out"
      echo "[[ upgrade sing-box"
      ;;
    s3-backup.age)
      echo Updating minio creds for user: backup...
      echo -n "backup:$(mkpassword 50 | tr ':' -d)" | writeout "$arg"
      echo "[[ terraform minio"
      echo "[[ upgrade backup-s3"
      ;;
    minio-creds.age)
      echo Updating minio creds for user: admin...
      echo -ne "MINIO_ROOT_USER=admin\nMINIO_ROOT_PASSWORD=$(mkpassword 50)" | writeout $arg
      echo "[[ upgrade minio"
      ;;
  esac
done
