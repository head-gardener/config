function forget_host -d "Remove host from known hosts"
  set host $argv[1]
  set known_hosts "$HOME/.ssh/known_hosts"
  if not grep "^$host" $known_hosts > /dev/null
    echo "Host isn't in known_hosts!"
    return 0
  end
  echo "Following entries will be deleted:"
  sed "/^$host.*/d" $known_hosts | diff "$known_hosts" -
  switch (read -P "Do you want to delete them? (Y/n):")
    case N n
      return 1
  end
  sed "/^$host.*/d" $known_hosts -i
end
