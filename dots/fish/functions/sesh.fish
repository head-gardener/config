function sesh -d "Starts a new tmux session from the given target, which is queried from zoxide or represents an absolute path" -a target
  if [ -n "$target" ]
    if not [ -d "$(builtin realpath $target)" ]
      set path "$(zoxide query "$target" || builtin realpath $target)"
    else
      set path "$(builtin realpath $target)"
    end
    [ -n "$path" ] || return 1
    if not [ -d "$path" ]
      echo -n "'"
      set_color -o magenta;
      echo -n "$path"
      set_color normal
      echo "' isn't a directory."
      switch (read -P "Should it be created? (y/N): ")
        case Y y
          true
        case '*'
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

  if tmux has-session -t "$name"
    echo -n "Session ";
    set_color -o red;
    echo -n "$name"
    set_color normal
    echo -n " already exists!"
    switch (read -P "Rename to $name-2? (N/y): ")
      case Y y
        true
      case '*'
        return 1
    end
    set name "$name-2"
  end

  tmux new-session -d -s "$name" -c "$path"
  tmux switch-client -t "$name"
end
