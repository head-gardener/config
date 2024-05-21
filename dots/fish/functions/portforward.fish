function portforward -d "Forwards a port from a remote to localhost over ssh" -a remote port
  ssh $remote -L $port:localhost:$port -vvv read 2>&1 | rg forward
end
