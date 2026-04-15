function nix-desc -d "Get package description"
  argparse --min-args=1 -- $argv

  set target "$argv[1]"
  set flake "$(string split -f 1 -n '#' "$target")"
  set pkg "$(string split -f 2 -n '#' "$target")"
  set sys "$(nix eval --impure --raw --expr 'builtins.currentSystem')"

  nix eval "$flake#legacyPackages.$sys.$pkg.meta.description" \
   || nix eval "$flake#legacyPackages.$sys.$pkg.meta.description"
end
