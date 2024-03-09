function nom-rebuild-d --wraps nixos-rebuild --description "nom-wrapped doas nixos-rebuild"
  doas w > /dev/null
  doas nixos-rebuild $argv --log-format internal-json -v 2>| nom --json
end

function nom-rebuild --wraps nixos-rebuild --description "nom-wrapped nixos-rebuild"
  nixos-rebuild $argv --log-format internal-json -v 2>| nom --json
end
