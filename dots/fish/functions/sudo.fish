function sudo --wraps=doas --description 'alias sudo=doas'
  doas $argv
        
end
