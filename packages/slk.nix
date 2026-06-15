{
  stdenvNoCC,
  lib,
  fetchurl,
}: let
  version = "0.8.4";
  baseUrl = "https://github.com/gammons/slk/releases/download/v${version}";
  sources = {
    x86_64-linux = fetchurl {
      url = "${baseUrl}/slk_${version}_linux_x86_64.tar.gz";
      sha256 = "0w68pxahm4vmwjvjb345wp97njrh1p5m8iys8rzim6hr5v1f2s7m";
    };
    aarch64-linux = fetchurl {
      url = "${baseUrl}/slk_${version}_linux_arm64.tar.gz";
      sha256 = "1qnihf77adcjxl0aw0m6bmq2nbnqgg4l60f6v463l12g3pnr1c1i";
    };
  };
in
  stdenvNoCC.mkDerivation {
    pname = "slk";
    inherit version;

    src = sources.${stdenvNoCC.hostPlatform.system} or (throw "slk: unsupported system ${stdenvNoCC.hostPlatform.system}");

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 slk $out/bin/slk
      install -Dm644 LICENSE $out/share/licenses/slk/LICENSE
      install -Dm644 README.md $out/share/doc/slk/README.md
      runHook postInstall
    '';

    meta = {
      description = "Open-source, daily-driver TUI Slack client built in Go";
      homepage = "https://getslk.sh/";
      license = lib.licenses.mit;
      mainProgram = "slk";
      platforms = ["x86_64-linux" "aarch64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
