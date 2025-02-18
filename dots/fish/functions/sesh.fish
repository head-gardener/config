function sesh -d "Starts a new tmux session from the given target, which is queried from zoxide or represents an absolute path" -a target
  if [ -n "$target" ]
    set target "$(realpath $target)"
    set path "$(zoxide query "$target" || echo "$target")"
    if not [ -d "$path" ]
      switch (read -P "'$path' not a directory. Should it be created? (Y/n): ")
        case N n
          return 1
      end
      mkdir -vp "$path"
      [ "$status" -eq 0 ] || return
    end
  else
    set path "$(zoxide query -i)"
    [ "$status" -eq 0 ] || return
  end
  set name "$(path basename $path)"

  echo -n "name: ";
  set_color -o red;
  echo -n "$name"
  set_color normal
  echo -n ", path: "
  set_color -o magenta;
  echo "$path"
  set_color normal

  switch (read -P "Ok? (Y/n): ")
    case N n
      return 1
  end

  tmux new-session -d -s "$name" -c "$path"
  tmux switch-client -t "$name"
end
