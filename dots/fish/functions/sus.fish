function sus --wraps='systemctl --user' --description 'alias sus systemctl --user'
  systemctl --user $argv
        
end
