function unnix -d 'Make a symlinked file editable by copying it' -a file
  if not [ -L "$file" ]
    echo "$file is not a symlink, aborting"
    return 1
  end
  sudo mv "$file" "$file.old"
  sudo cp "$file.old" "$file"
  sudo rm "$file.old"
  sudo chmod +w "$file"
end
