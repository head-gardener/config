function note -d "Opens an unmanaged note with the given topic" -a topic
  switch $topic
    case --list
      ls "$HOME/notes/unmanaged" | sed -n '/.norg/p' | sed 's/.norg//'
      return 0
    case --select
      set topic (ls "$HOME/notes/unmanaged" | sed -n '/.norg/p' | sed 's/.norg//' | dmenu)
      test -n "$topic" || return 1
  end

  set path "$HOME/notes/unmanaged/$topic.norg"
  set capitalized (echo "$topic" | sed -e 's/\b\(.\)/\u\1/g')
  set args (test -e "$path" || echo "+\"normal i* $capitalized\"")
  sh -c "nvim $path $args"
end
