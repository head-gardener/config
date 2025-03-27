function nix3-shell-expr \
  -a expr \
  -d 'Open nix3 shell from an expression rather than a url'

  nix shell --impure --expr \
    "let s = (builtins.getFlake \"s\").legacyPackages.\${builtins.currentSystem}; in $expr" \
    $argv[2..]
end
