function nix3-expr \
  -a op \
  -a expr \
  -d 'Build/shell/develop a nix expression with automatic flake imports.'

  # flatten a flake to make it structurally resemble cli flake urls.
  set -l shorten_func '
    shorten = f:
      let
        legacyPackages = if f ? "legacyPackages" then f.legacyPackages.${builtins.currentSystem} else {};
        packages = if f ? "packages" then f.packages.${builtins.currentSystem} else {};
        devShells = if f ? "devShells" then f.devShells.${builtins.currentSystem} else {};
      in f
        // legacyPackages
        // packages
        // {
          inherit legacyPackages packages devShells;
        }'

  nix $op --impure --expr \
    "let
      $shorten_func;
      $(for f in $(nix registry list);
          echo -n '"'
          echo -n "$f" | sed -nr 's/.*flake:(.*)\s.*/\1/p'
          echo -n '"'
          echo " = shorten (builtins.getFlake \"$(echo "$f" | cut -d' ' -f3)\");"
        end)
      dot = shorten (builtins.getFlake \"git+file:$(pwd)\");
      f = p: shorten (builtins.getFlake p);
    in $expr" \
    $argv[3..]
end
