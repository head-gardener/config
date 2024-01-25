# Use to prefetch venvs when python bloatware uses a million
# unpackaged dependencies. If it doesn't work due to inconsistent
# output hash, try reducing requirements.txt in favor of
# nix-packaged libraries.

{ stdenv, lib }:

{ req, name, python, pythonPackages, hash ? lib.fakeSha256
, outputHashAlgo ? "sha256", inputs ? [] }:

stdenv.mkDerivation {
  name = name + ".tar.gz";
  version = "1.0.0";

  outputHash = hash;
  inherit outputHashAlgo;

  inherit req;

  unpackPhase = ''
    echo "$req" > requirements.txt

    unpinned_packages=$(sed -n '/^[^#]/!d; /==/!{p}' requirements.txt)
    if [[ -n $unpinned_packages ]]; then
      echo -e "\e[31mWarning: Some packages aren't pinned, which may result in hash mismatches when rebuilding!\nOffending entries:"
      echo -e "$unpinned_packages\e[0m"
    fi
  '';

  configurePhase = ''
    mkdir venv
    python -m venv venv
    . venv/bin/activate
  '';

  buildPhase = ''
    pip install --no-cache-dir -r requirements.txt
  '';

  installPhase = ''
    tar --owner=0 --group=0 --numeric-owner --format=gnu \
        --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
        -czf $out venv
  '';

  buildInputs = [ python pythonPackages.wheel ] ++ inputs;
}
