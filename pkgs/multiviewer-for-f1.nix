{ stdenv
, fetchurl
, lib
, makeWrapper
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
, libpulseaudio
, libudev0-shim
, libxkbcommon
, mesa
, nspr
, nss
, pango
, xorg
, wayland
}:
let
  inherit (stdenv.hostPlatform) system;
  pname = "multiviewer-for-f1";
  version = "1.22.1";
  id = "113204550";

  meta = with lib; {
    description = "Unofficial desktop client for F1 TV®";
    homepage = "https://multiviewer.app";
    downloadPage = "https://multiviewer.app/download";
    license = licenses.unfree;
    maintainers = with maintainers; [ babeuh ];
    platforms = [ "x86_64-linux" ];
  };

  src = fetchurl {
    url = "https://releases.multiviewer.dev/download/${id}/multiviewer-for-f1_${version}_amd64.deb";
    sha256 = "sha256-Dfqk/jHICjBEoD+r2YovFK88LcQ4RPLLLh3/P4A4NQ4=";
  };

  deps = [
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
    libpulseaudio
    libudev0-shim
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
    wayland
  ];
in
stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ makeWrapper ];

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      ${dpkg}/bin/dpkg-deb -x $src . || true
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/multiviewer-for-f1

      cp -a usr/share/* $out/share
      cp -a usr/lib/multiviewer-for-f1 $out/share/
      mv $out/share/multiviewer-for-f1/"MultiViewer for F1" $out/share/multiviewer-for-f1/multiviewer-for-f1

      rpath="$out/share/multiviewer-for-f1"
      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath $rpath $out/share/multiviewer-for-f1/multiviewer-for-f1

      makeWrapper $out/share/multiviewer-for-f1/multiviewer-for-f1 $out/bin/multiviewer-for-f1 \
        --add-flags $out/share/multiviewer-for-f1/resources/app \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath deps }:$out/share/multiviewer-for-f1"

      runHook postInstall
    '';
  }
