function unnix -d 'Make a symlinked file editable by copying it' -a file
  if not [ -L "$file" ]
    echo "$file is not a symlink, aborting"
    return 1
  end
  doas mv "$file" "$file.old"
  doas cp "$file.old" "$file"
  doas rm "$file.old"
  doas chmod +w "$file"
end
