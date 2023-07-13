{ stdenv
, fetchzip
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
  id = "116221066";

in
stdenv.mkDerivation {
  pname = "multiviewer-for-f1";
  inherit version;

  src = fetchzip {
    url = "https://releases.multiviewer.dev/download/${id}/MultiViewer.for.F1-linux-x64-${version}.zip";
    sha256 = "sha256-fnGVn469wpUQk77q8/px7X8xoTUvOiR/nwYppsDF+PQ=";
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share

    mv ./* $out/share

    makeWrapper $out/share/"MultiViewer for F1" $out/bin/multiviewer-for-f1 \
      --add-flags $out/share/resources/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libudev0-shim ] }:$out/share/\"Multiviewer for F1\""

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
