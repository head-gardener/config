function rootgate -d "Run a root gate"
  [ -e /tmp/rg_in ]
  and begin echo 'Already opened!'; return 1; end
  mkfifo /tmp/rg_in
  sudo sh -c ' \
    trap "echo exiting...; rm /tmp/rg_in; exit" exit
    tail -f /tmp/rg_in | stdbuf -oL sh'
end

function rgs -d "Send a command to the root gate"
  echo "cd $(pwd)" > /tmp/rg_in
  echo $argv > /tmp/rg_in
end
