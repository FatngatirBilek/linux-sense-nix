# Kernel module derivation for linux-sense (linuwu_sense driver)
#
# Sources the driver/ directory from this repo.
# Built with clang + ld.lld to match CachyOS/LLVM-built kernels.
{
  stdenv,
  lib,
  kernel,
  lld,
  clang,
  src,
}:
stdenv.mkDerivation {
  pname = "linuwu-sense";
  version = "25.701";
  name = "linuwu-sense-25.701-${kernel.modDirVersion}";

  inherit src;

  setSourceRoot = ''
    export sourceRoot=$(pwd)/driver
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ lld clang ];

  makeFlags = [
    "-C" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
    "CC=clang"
    "LD=ld.lld"
  ];

  NIX_CFLAGS_COMPILE = "-Wno-unused-command-line-argument";
  buildFlags   = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=$(out)" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Acer Nitro/Predator WMI driver with 4-zone RGB keyboard support (linuwu_sense)";
    homepage    = "https://github.com/PoPoGne/linux-sense";
    license     = lib.licenses.gpl2Plus;
    platforms   = lib.platforms.linux;
  };
}
