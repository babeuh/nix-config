{ stdenv
, fetchurl
, lib
, makeWrapper
, autoPatchelfHook
, dpkg
, alsa-lib
, at-spi2-atk
, cairo
, cups
, dbus
, expat
, ffmpeg
, glib
, gtk3
, libdrm
, libudev0-shim
, libxkbcommon
, mesa
, nspr
, nss
, pango
, xorg
}:

let
  version = "1.24.0";
  id = "116221064";

in
stdenv.mkDerivation {
  pname = "multiviewer-for-f1";
  inherit version;

  src = fetchurl {
    url = "https://releases.multiviewer.dev/download/${id}/multiviewer-for-f1_${version}_amd64.deb";
    sha256 = "sha256-eCtCw0b8XnQ7EUBZAw6tloY5EIUnHNB3GuWQV61jAIo=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    ffmpeg
    glib
    gtk3
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    xorg.libX11
    xorg.libXcomposite
    xorg.libxcb
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    runHook preUnpack
    ${dpkg}/bin/dpkg-deb -x $src . || true
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/multiviewer-for-f1

    cp -a usr/share/* $out/share
    cp -a usr/lib/multiviewer-for-f1 $out/share/
    mv $out/share/multiviewer-for-f1/"MultiViewer for F1" $out/share/multiviewer-for-f1/multiviewer-for-f1

    makeWrapper $out/share/multiviewer-for-f1/multiviewer-for-f1 $out/bin/multiviewer-for-f1 \
      --add-flags $out/share/multiviewer-for-f1/resources/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libudev0-shim ] }:$out/share/multiviewer-for-f1"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Unofficial desktop client for F1 TV®";
    homepage = "https://multiviewer.app";
    downloadPage = "https://multiviewer.app/download";
    license = licenses.unfree;
    maintainers = with maintainers; [ babeuh ];
    platforms = [ "x86_64-linux" ];
  };
}
