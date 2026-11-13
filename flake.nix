{
  description = "Linux Sense — Acer Nitro/Predator control panel for Linux";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
    src    = self;
  in {

    # ── Packages ─────────────────────────────────────────────────────────────
    packages.${system} = {
      # GUI application + daemon wrappers
      linux-sense = pkgs.callPackage ./nix/app.nix { inherit src; };

      # Kernel module — requires a kernelPackages set, exposed for reference.
      # For actual use, consume via nixosModules.default or callPackage directly.
      linuwu-sense-driver = pkgs.linuxPackages.callPackage ./nix/driver.nix { inherit src; };

      default = self.packages.${system}.linux-sense;
    };

    # ── NixOS module ─────────────────────────────────────────────────────────
    nixosModules.linux-sense = { config, pkgs, lib, ... }: {
      imports = [ ./nix/module.nix ];

      # Inject our package into pkgs so the module's default value resolves
      nixpkgs.overlays = [
        (final: _: {
          linux-sense = final.callPackage ./nix/app.nix { inherit src; };
        })
      ];
    };
    nixosModules.default = self.nixosModules.linux-sense;

    # ── Dev shell ─────────────────────────────────────────────────────────────
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        (python3.withPackages (p: [ p.pyside6 ]))
        qt6.qtdeclarative
        qt6.qtsvg
        qt6.qttools
      ];
      shellHook = ''
        echo "linux-sense dev shell"
        echo "Run:  python app/linux_sense.py"
      '';
    };
  };
}
