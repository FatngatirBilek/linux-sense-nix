{
  description = "Linux Sense — Acer Nitro/Predator control panel for Linux";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    src = self;
  in {
    packages.${system} = {
      linux-sense = pkgs.callPackage ./nix/app.nix {inherit src;};

      linuwu-sense-driver = pkgs.linuxPackages.callPackage ./nix/driver.nix {inherit src;};

      default = self.packages.${system}.linux-sense;
    };

    nixosModules.linux-sense = {
      config,
      pkgs,
      lib,
      ...
    }: {
      imports = [./nix/module.nix];

      # Inject our package into pkgs so the module's default value resolves
      nixpkgs.overlays = [
        (final: _: {
          linux-sense = final.callPackage ./nix/app.nix {inherit src;};
        })
      ];
    };
    nixosModules.default = self.nixosModules.linux-sense;

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        (python3.withPackages (p: [p.pyside6]))
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
