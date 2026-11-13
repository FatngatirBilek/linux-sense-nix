# GUI application + daemon for linux-sense
#
# The app uses PySide6/QML and resolves all assets relative to __file__,
# so we simply copy the app/ and daemon/ trees into $out/lib/linux-sense
# and generate thin wrapper scripts.
{
  lib,
  python3Packages,
  qt6,
  src,
}:
python3Packages.buildPythonApplication {
  pname = "linux-sense";
  version = "1.0.1";
  format = "other";

  inherit src;

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  propagatedBuildInputs = [
    python3Packages.pyside6
    qt6.qtdeclarative
    qt6.qtsvg
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # App and daemon sources
    mkdir -p $out/lib/linux-sense
    cp -r app daemon $out/lib/linux-sense/

    # Launcher wrappers
    mkdir -p $out/bin
    cat > $out/bin/linux-sense <<SH
#!/bin/sh
exec ${python3Packages.python.interpreter} $out/lib/linux-sense/app/linux_sense.py "\$@"
SH
    chmod +x $out/bin/linux-sense

    cat > $out/bin/linux-sense-daemon <<SH
#!/bin/sh
exec ${python3Packages.python.interpreter} $out/lib/linux-sense/daemon/linux-sense-daemon.py "\$@"
SH
    chmod +x $out/bin/linux-sense-daemon

    # Icons
    install -D -m644 logo/out/linux-sense.svg \
      $out/share/icons/hicolor/scalable/apps/linux-sense.svg
    for s in 16 24 32 48 64 128 256 512; do
      [ -f "logo/out/linux-sense-$s.png" ] && \
        install -D -m644 "logo/out/linux-sense-$s.png" \
          "$out/share/icons/hicolor/''${s}x''${s}/apps/linux-sense.png"
    done

    # Desktop entry
    install -Dm644 /dev/stdin $out/share/applications/linux-sense.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Linux Sense
GenericName=Laptop control
Comment=Profiles, fans, keyboard lighting and battery
Exec=linux-sense
Icon=linux-sense
Terminal=false
Categories=Settings;HardwareSettings;
Keywords=acer;nitro;predator;nitrosense;fans;rgb;keyboard;profiles;battery;
StartupWMClass=linux-sense
EOF

    runHook postInstall
  '';

  # Let wrapQtAppsHook inject Qt plugin paths + our PYTHONPATH
  postFixup = ''
    wrapQtApp $out/bin/linux-sense \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  meta = {
    description = "Control panel for Acer Nitro/Predator laptops on Linux — NitroSense alternative";
    homepage    = "https://github.com/PoPoGne/linux-sense";
    license     = lib.licenses.gpl3;
    platforms   = lib.platforms.linux;
    mainProgram = "linux-sense";
  };
}
