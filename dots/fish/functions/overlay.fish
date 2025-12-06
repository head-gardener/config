function overlay -d "Add a tmpfs overlay over a dir"
  set help "Add a tmpfs overlay over a dir."
  argparse --min-args=1 'h/help' -- $argv
  or begin; echo $help >&2; return 1; end

  if set -ql _flag_h
    echo $help >&2
    return 1
  end

  set target "$(builtin realpath "$argv[1]")"
  df "$target" | grep "overlay" > /dev/null
  and begin; echo "'$target' already overlayed!"; return 1; end

  set root "/tmp/$(pathtofile "$target")"
  if [ -d "$root/upper" ]
    echo "Warning: '$root/upper' already exists, changes from there will be applied. To clear them, run 'unoverlay --clear $argv[1]'"
  end
  mkdir -p "$root/upper" "$root/work" "$root/merged"

  set opts "lowerdir=$target,upperdir=$root/upper,workdir=$root/work"
  echo "Mounting overlayfs with -o $opts..."
  sudo mount -t overlay overlay \
    -o "$opts" \
    "$root/merged"
  [ "$status" -eq 0 ] || begin echo "Can't mount an overlay!"; return 1; end
  sudo mount --bind "$root/merged" "$target"
  [ "$status" -eq 0 ] || begin echo "Can't bind mount!"; return 1; end
  echo "Success!"
end

function unoverlay -d "Clear a tmpfs overlay created by `overlay`"
  set help "Clear a tmpfs overlay created by `overlay`. Use -c/--clear to wipe all changes, which are otherwise preserved."
  argparse --min-args=1 'h/help' 'c/clear' -- $argv
  or begin; echo $help >&2; return 1; end

  if set -ql _flag_h
    echo $help >&2
    return 1
  end

  set target "$(builtin realpath "$argv[1]")"
  set root "/tmp/$(pathtofile "$target")"
  sudo umount "$target"
  [ "$status" -eq 0 ] || begin echo "Can't unmount bind mount!"; return 1; end
  sudo umount "$root/merged"
  [ "$status" -eq 0 ] || begin echo "Can't unmount overlay mount!"; return 1; end
  if set -ql _flag_c
    sudo rm -r "$root"
    echo "Success!"
  else
    echo "Success! All changes saved to '$root/upper'"
  end
end
