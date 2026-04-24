# tmux extras

complete -e tmuxx
set -l cmds bind-rerun update-ping help

function __tmuxx_tabs_completion -d "List tabs for completion"
  tmux display-pane -b -d 500
  tmux list-panes -s -F '#{pane_id}'
  tmux list-panes -F '#{pane_index}'
  tmux list-panes -s -F '#{window_index}.#{pane_index}'
  tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}'
end

complete -c tmuxx --no-files \
  -n "not __fish_seen_subcommand_from $cmds" \
  -a "$cmds" \
  -d 'Subcommand'

complete -c tmuxx --no-files \
  -n "__fish_seen_subcommand_from bind-rerun" \
  -s h -l help
complete -c tmuxx --no-files \
  -n "__fish_seen_subcommand_from bind-rerun && __fish_is_nth_token 3" \
  -a '(__tmuxx_tabs_completion)' -k \
  -d 'Pane'
complete -c tmuxx --no-files \
  -n "__fish_seen_subcommand_from bind-rerun && __fish_is_nth_token 2" \
  -a 'C-s C-r' \
  -d 'Keybind'

complete -c tmuxx --no-files \
  -n "__fish_seen_subcommand_from update-ping" \
  -s h -l help
complete -c tmuxx --no-files \
  -n "__fish_seen_subcommand_from update-ping" \
  -a '(__tmuxx_tabs_completion)' -k \
  -d 'Pane'

function tmuxx -d "Tmux helper scripts"
  set help "\
Tmux helper scripts
Target syntax is session:window.pane"

  if [ $(count argv) -lt 1 ]
    echo "Command name missing!"
    return 1
  end

  set cmd $argv[1]
  set argv $argv[2..]
  switch "$cmd"
    case 'bind-rerun'
      tmuxx-bind-rerun $argv
    case 'update-ping'
      tmuxx-update-ping $argv
    case *
      echo $help
  end
end

function tmuxx-bind-rerun -d "Bind a key to rerun a command in a shell pane"
  set help "Usage: tmuxx bind-rerun <key> <target>"
  argparse --min-args=2 'h/help' -- $argv
  or begin; echo $help; return 1; end

  if set -ql _flag_h
    echo $help
    return 0
  end

  tmux bind-key \
    -N "Send Up and Enter to $argv[2]" \
    "$argv[1]" \
    "send-keys -t $argv[2] 'Up' 'Enter'"
end

function tmuxx-update-ping -d "Notifies on updates to pane contents"
  set help "Usage: tmuxx bind-rerun <target> [notify-send args]"
  argparse --min-args=1 'h/help' -- $argv
  or begin; echo $help; return 1; end

  if set -ql _flag_h
    echo $help
    return 0
  end

  set old_len "$(tmux capture-pane -p -t "$argv[1]" -S - -J | wc -l)"
  while true;
    sleep 5
    set -l new_len "$(tmux capture-pane -p -t "$argv[1]" -S - -J | wc -l)"
    if [ $new_len -gt $old_len ];
      notify-send "Got update on $argv[1]" $argv[2..]
    end
    set old_len $new_len
  end
end
