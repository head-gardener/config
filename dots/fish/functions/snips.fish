function docs -a type -d "Find and open docs symlinked by NixOS"
  [ -z "$type" ] && set type 'index.html'
  set tgt $(fd "$type" /run/current-system/sw/share/doc/ --follow | fzf)
  if [ -n "$tgt" ]
    xdg-open "$tgt"
  end
end
