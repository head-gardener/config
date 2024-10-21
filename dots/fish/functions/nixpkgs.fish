function nixpkgs -d 'Opens nixpkgs from registry in RO nvim'
  set path (nix registry list --offline | sed -rn 's/system flake:nixpkgs path:([^\?]*).*/\1/p')
  pushd $path
  nvim -R .
  popd
end
