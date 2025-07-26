_: _: _: {}
# inputs: final: prev: {
#   projectm4 = final.libsForQt5.callPackage ./projectm4.nix { };

#   projectmsdl = final.callPackage ./projectmsdl.nix { };

#   projectm-presets-cotc = final.stdenv.mkDerivation {
#     pname = "projectm-presets-cotc";
#     version = "4e0bf9f0";
#     src = final.fetchFromGitHub {
#       owner = "projectM-visualizer";
#       repo = "presets-cream-of-the-crop";
#       rev = "4e0bf9f0ca92dcdf00b049701e20ef57b1d2c406";
#       hash = "sha256-a8FVqI9yb5KWP4M5T6OLX+SsHT6qxhHUsMJ6witf+ZA=";
#     };
#     installPhase = "mkdir $out; cp * $out/ -r";
#   };

#   projectm-presets-en-d = final.stdenv.mkDerivation {
#     pname = "projectm-presets-en-d";
#     version = "fff71ea8";
#     src = final.fetchFromGitHub {
#       owner = "projectM-visualizer";
#       repo = "presets-en-d";
#       rev = "fff71ea81223109f3558351667eef851f2781c96";
#       hash = "sha256-aRxZRpa9uQkSgKm/m/Fkc+TWqfKdCYLgUYvZFh2Ugqk=";
#     };
#     installPhase = "mkdir $out; cp * $out/ -r";
#   };

#   projectm-presets-classic = final.stdenv.mkDerivation {
#     pname = "projectm-presets-classic";
#     version = "fff71ea8";
#     src = final.fetchFromGitHub {
#       owner = "projectM-visualizer";
#       repo = "presets-projectm-classic";
#       rev = "14a6244a7d32eb7e114e1a92d1cb93358cdcc54a";
#       hash = "sha256-BfhTC6b9oA3+nQES1pQ9WAUA13Mg4OJJq9huSQo29pM=";
#     };
#     installPhase = "mkdir $out; cp * $out/ -r";
#   };
# }
