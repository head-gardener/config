if not set -q CODE_DIR
  set CODE_DIR "$HOME/code"
  [ -d "$CODE_DIR" ] && return
  set CODE_DIR "$HOME/Code"
  [ -d "$CODE_DIR" ] && return
end

complete -c codectl -a 'clone' --no-files

function codectl -d "Shortcuts for code dir manipulations"
  set help "Usage: code clone | help"
  if [ $(count argv) -lt 1 ]
    echo "Command name missing!"
    echo $help
    return 1
  end
  set cmd $argv[1]
  set argv $argv[2..]
  switch "$cmd"
    case 'clone'
      codectl-clone $argv
    case 'init'
      codectl-init $argv
    case 'help' '*'
      echo $help
      return
  end
end

function codectl-clone -d "Clone a repo into the code dir"
  set help "Usage: code clone [-s] <tgt> <git args>"
  argparse --min-args=1 'h/help' 's/sesh' -- $argv
  or begin; echo $help; return 1; end

  if set -ql _flag_h
    echo $help
    return 0
  end

  set -l tgt $argv[1]
  set -l argv $argv[2..]
  # can match on a relative path but that not really a usecase
  if string match -qr '^[^/]+/[^/]+$' "$tgt"
    set tgt "git@github.com:$tgt"
  end

  set name $(string match -gr '/([^/]+)$' "$tgt")

  git clone "$tgt" "$CODE_DIR/$name" $argv
  or return 1

  if set -ql _flag_s
    sesh "$CODE_DIR/$name"
  end
end
