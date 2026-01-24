{
  pname,
  version,
  src,

  stdenv,
  cmake,
  libx11,
  libxcb,
  libxcb-util,
  libxcb-cursor,
  libxcb-keysyms,
  libxkbcommon,
  freetype,
  pkg-config,
  pango,
  cairo,
  fontconfig,

  vst3sdk,
}:
let
  patch = ''
    @@ -89,6 +89,7 @@
         ''${VST3_SDK_ROOT}/public.sdk/source/vst/vstaudioeffect.cpp
         ''${VST3_SDK_ROOT}/public.sdk/source/vst/vstaudioprocessoralgo.h
         ''${VST3_SDK_ROOT}/public.sdk/source/vst/vsteditcontroller.h
    +    ''${VST3_SDK_ROOT}/public.sdk/source/common/commonstringconvert.cpp
         ''${VST3_SDK_ROOT}/pluginterfaces/base/ibstream.h
         ''${VST3_SDK_ROOT}/pluginterfaces/base/ustring.h
         ''${VST3_SDK_ROOT}/pluginterfaces/vst/ivstevents.h
  '';
in stdenv.mkDerivation {
  inherit pname version src;

  preConfigure = ''
    export HOME="$(pwd)"

    sed -i \
      -e "s|/usr/local/lib/vst3|$out/lib/vst3/$pname.vst3/Contents/${stdenv.hostPlatform.system}|" \
      ./CMakeLists.txt

    patch ./CMakeLists.txt <<'EOF'
    ${patch}
    EOF
  '';

  cmakeFlags = [
    "-DVST3_SDK_ROOT=${vst3sdk}"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    libx11
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-keysyms
    libxkbcommon
    freetype
    pango
    cairo
    fontconfig
  ];
}
