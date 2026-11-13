# NixOS module for linux-sense
#
# Usage — in your NixOS configuration:
#
#   imports = [ linux-sense-nix.nixosModules.default ];
#   services.linux-sense.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.linux-sense;
in
{
  options.services.linux-sense = {
    enable = lib.mkEnableOption "Linux Sense daemon and control panel for Acer Nitro/Predator laptops";

    package = lib.mkOption {
      type        = lib.types.package;
      default     = pkgs.linux-sense;
      description = "The linux-sense app package (GUI + daemon wrappers).";
    };
  };

  config = lib.mkIf cfg.enable {

    # ── Kernel driver ────────────────────────────────────────────────────────
    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./driver.nix {
        src = ../.;
      })
    ];

    # linuwu_sense replaces the stock acer_wmi; uleds provides the kbd LED
    boot.kernelModules          = [ "linuwu_sense" "uleds" ];
    boot.blacklistedKernelModules = [ "acer_wmi" ];

    # ── App ──────────────────────────────────────────────────────────────────
    environment.systemPackages = [ cfg.package ];

    # ── Daemon service ───────────────────────────────────────────────────────
    systemd.services.linux-sense = {
      description = "Linux Sense daemon — Acer profiles, fans, keyboard and battery";
      after   = [ "systemd-modules-load.service" ];
      wants   = [ "systemd-modules-load.service" ];
      wantedBy = [ "multi-user.target" ];

      # Give the daemon loginctl, modprobe, and busctl (OSD is optional/no-op on non-KDE)
      path = with pkgs; [ systemd kmod util-linux ];

      serviceConfig = {
        Type       = "simple";
        ExecStart  = "${cfg.package}/bin/linux-sense-daemon";
        Restart    = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
