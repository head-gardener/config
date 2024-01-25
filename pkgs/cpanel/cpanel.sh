#!/usr/bin/env sh

rtdir="$XDG_RUNTIME_DIR/cpanel"

getnid() {
  mkdir -p "$rtdir"
  echo '' >> "$rtdir/nid$1"
  cat "$rtdir/nid$1"
}

putnid() {
  echo "$2" > "$rtdir/nid$1"
}

notif() {
  nid=$(getnid "$1")
  args=(-t 1500 -p -u low)
  if [ -n "$nid" ]; then
    args+=(-r "$nid")
  fi
  new=$(notify-send -p -u low "$1" "$2" "${args[@]}")
  echo "new $new"
  putnid "$1" "$new"
}

pwnotif() {
  tt=$(pw-volume status\
    | jq -r\
    'if .percentage then "\(.percentage)%" else .tooltip end')
  notif "Volume" "set to $tt"
}

blnotif() {
  br=$(brightnessctl set -e "5%$1" -m | cut -d',' -f4)
  notif "Backlight" "set to $br"
}

case "$1" in
  volup)
    pw-volume change '+5%'
    pwnotif  
    ;;

  voldown)
    pw-volume change '-5%'
    pwnotif  
    ;;

  volmute)
    pw-volume mute toggle
    pwnotif  
    ;;

  blup)
    blnotif '+'
    ;;

  bldown)
    blnotif '-'
    ;;

  *)
    notif "Error" "Invalid command \"$1\" sent to cpanel"
    ;;
esac
