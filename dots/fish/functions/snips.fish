function docs -a type -d "Find and open docs symlinked by NixOS"
  [ -z "$type" ] && set type 'index.html'
  set tgt $(fd "$type" /run/current-system/sw/share/doc/ --follow | fzf)
  if [ -n "$tgt" ]
    xdg-open "$tgt"
  end
end

function nix-fzf-bin -d "Find an executable's dir in nix store"
  set r "$(fd '^bin$' -d2 /nix/store -td | fzf --preview 'ls {}')"
  [ -e "$r" ] || return 1
  echo -n "$r"
end
