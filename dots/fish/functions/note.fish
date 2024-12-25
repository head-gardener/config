function note -d "Opens an unmanaged note with the given topic" -a topic
  set basedir "$HOME/notes"

  function list -a basedir
    find "$basedir" -type f -name '*.norg' | sed "s|$basedir/\(.*\)\.norg|\1|"
  end

  switch $topic
    case --list
      list "$basedir"
      return 0
    case --select
      set topic "$(list "$basedir" | dmenu)"
      test -n "$topic" || return 1
  end

  pushd "$basedir"

  # move to unmanaged by default
  if test ! -e "$basedir/$topic.norg" && not string match -q "*/*" "$topic"
    set topic "unmanaged/$topic"
  end

  set path "$basedir/$topic.norg"
  set title "$(echo "$topic" | sed 's/.*\///')"
  set capitalized (echo "$title" | sed -e 's/\b\(.\)/\u\1/g')
  set args (test -e "$path" || echo "+\"normal i* $capitalized\"")
  sh -c "nvim $path $args"

  popd
end
