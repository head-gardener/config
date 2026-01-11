function overlay -d "Add a tmpfs overlay over a dir"
  set help "Add a tmpfs overlay over a dir.
  -u/--unlink - replace symlinks with files.
  -w/--writeable - ensure all overlayed files are writeable."
  argparse --min-args=1 'w/writeable' 'u/unlink' 'h/help' -- $argv
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

  if not findmnt "$root" > /dev/null
    sudo mount --mkdir -t tmpfs $(pathtofile "$target") "$root"
    [ "$status" -eq 0 ] || echo "Can't mount tmpfs!"
  end
  mkdir -p "$root/upper" "$root/lower" "$root/work" "$root/merged"
  sudo chown --recursive "$(stat -c %u "$target"):$(stat -c %g "$target")" "$root"
  sudo chmod --recursive "$(stat -c %a "$target")" "$root"

  sudo mount --bind "$target" "$root/lower"

  [ "$status" -eq 0 ] || begin echo "Can't bind mount lower dir!"; return 1; end
  set opts "lowerdir=$target,upperdir=$root/upper,workdir=$root/work"
  echo "Mounting overlayfs with -o $opts..."
  sudo mount -t overlay overlay \
    -o "$opts" \
    "$root/merged"
  [ "$status" -eq 0 ] || begin echo "Can't mount an overlay!"; return 1; end

  if set -ql _flag_u
    cd "$target"

    for f in $(find -type l)
      sudo mkdir -p "$root/upper/$(dirname -- "$f")"
      sudo cp -a "$(readlink -f -- "$f")" "$root/upper/$f"
    end

    cd -
  end

  if set -ql _flag_w
    cd "$target"

    for f in $(find -follow ! -perm -u=w)
      if not [ -f "$root/upper/$f" ]
        sudo mkdir -p "$root/upper/$(dirname -- "$f")"
        sudo cp -a "$f" "$root/upper/$f"
      end
      sudo chmod u+w "$root/upper/$f"
    end

    cd -
  end

  sudo mount --bind "$root/merged" "$target"
  [ "$status" -eq 0 ] || begin echo "Can't bind mount!"; return 1; end
  echo "Success!"
end

function unoverlay -d "Clear a tmpfs overlay created by `overlay`"
  set help "Clear a tmpfs overlay created by `overlay`.
  -c/--clear - clear saved changes, preserve by default."
  argparse --min-args=1 'h/help' 'c/clear' -- $argv
  or begin; echo $help >&2; return 1; end

  if set -ql _flag_h
    echo $help >&2
    return 1
  end

  set target "$(builtin realpath "$argv[1]")"
  set root "/tmp/$(pathtofile "$target")"
  sudo umount "$target"
  [ "$status" -eq 0 ] || begin echo "Can't unmount bind mount! Is it overlayed?"; return 1; end
  sudo umount "$root/merged"
  [ "$status" -eq 0 ] || begin echo "Can't unmount overlay mount!"; return 1; end
  sudo umount "$root/lower"
  [ "$status" -eq 0 ] || begin echo "Can't unmount lower dir!"; return 1; end
  if set -ql _flag_c
    if findmnt "$root" >/dev/null
      sudo umount "$root"
      [ "$status" -eq 0 ] || begin echo "Can't unmount tmpfs!"; return 1; end
    else
      rm -rf "$root"
    end
    echo "Success!"
  else
    echo "Success! All changes saved to '$root/upper'"
  end
end
