{
  stdenv,
  lib,
  fetchFromGitHub,
  qt6,
  headsetcontrol,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "headsetcontrol-gui";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "HeadsetControl-GUI";
    repo = "HeadsetControl-GUI";
    tag = finalAttrs.version;
    hash = "sha256-thY2WeTw2MSUmVJZG8OpD79sk2WqJCLHoU0R8+HNDvQ=";
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  qmakeFlags = ["HeadsetControl-GUI.pro"];

  # qmake hardcodes lrelease to ${qtbase}/bin/lrelease, but in nixpkgs
  # lrelease ships in qttools, not qtbase. Rewrite the Makefile to use it.
  postConfigure = ''
    sed -i "s|[^[:space:]]*/bin/lrelease|${qt6.qttools}/bin/lrelease|g" Makefile
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 HeadsetControl-GUI $out/bin/headsetcontrol-gui

    runHook postInstall
  '';

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [headsetcontrol]}"
  ];

  meta = {
    description = "Qt GUI frontend for HeadsetControl";
    homepage = "https://github.com/HeadsetControl-GUI/HeadsetControl-GUI";
    license = lib.licenses.lgpl21Only;
    mainProgram = "headsetcontrol-gui";
    platforms = lib.platforms.linux;
  };
})
