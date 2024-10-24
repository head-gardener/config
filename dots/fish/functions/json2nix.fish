function json2nix -d "Convert json from stdin to nix (pipe `yq .` for yaml)"
  read -z input
  nix eval --expr "builtins.fromJSON \"$(echo $input | sed 's/"/\\\\"/g')\""
end
