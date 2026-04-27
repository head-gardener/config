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

function note-push-interactive -d "Interactively push entry to note via dmenu/nvim"
  set basedir "$HOME/notes"

  set selected (note --list | dmenu -p "Select note:")
  test -n "$selected" || return 1

  set tmpfile (mktemp --suffix=.norg)
  echo "* " > $tmpfile
  while read -l l;
    echo "$l" >> $tmpfile
  end

  nvim -c "set filetype=norg" '+normal ggA' $tmpfile

  set heading (head -1 $tmpfile | sed 's/^\* *//' | sed 's/\[.*\]//g' | tr -d '\n')
  tail -n +2 $tmpfile | note-push "$selected" "$heading"

  rm -f $tmpfile
end

function note-push -d "Push an entry into the “Misc” heading of a .norg note" -a note entry
  set help "Usage: note-push <note> <entry>"
  argparse --min-args=2 'h/help' -- $argv \
    || begin; echo $help; return 1; end

  if set -q _flag_h
    echo $help
    return 0
  end

  read -l entry_text
  while read -l l;
    set entry_text "$entry_text\n$l"
  end
  set note_path "$HOME/notes/$note.norg"
  set nonempty

  if not test -e $note_path
    touch $note_path
    set -e nonempty
  end

  set misc_line (grep -n -m1 '^* Misc' $note_path | cut -d: -f1)

  if test -z "$misc_line"
    set -q nonempty && echo "" | tee -a $note_path
    echo "* Misc" >> $note_path
    set misc_line (count (cat $note_path))
  end

  set tmp (mktemp)

  awk -v line=$misc_line -v block="$entry_text" -v heading="** $entry" '
  NR == line {
    print;
    print heading;
    n = split(block, parts, "\n");
    for (i = 1; i <= n; i++) {
        print "   " parts[i];
    }
    next;
  }
  { print }
  ' $note_path > $tmp

  mv $tmp $note_path
end
