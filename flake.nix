{
  description = "Modules to run services in rootless containers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, deploy-rs, sops-nix }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      system = "x86_64-linux";
      defaultModules = [
        ./modules.nix
        sops-nix.nixosModules.sops
      ];
    in {
      nixosConfigurations = {
        vpsDev = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = defaultModules ++ [
            ./nodes/vps/default.nix
            ./settings.dev.nix
          ];
        };
      };

      devShells."${system}".default = pkgs.mkShell {
        packages = [
          deploy-rs.packages."${system}".default
          pkgs.sops
        ];
      };

      deploy.nodes = {
        vpsDev = {
          sshUser = "root";
          hostname = "vps-dev";
          profiles = {
            system = {
              user = "root";
              path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.vpsDev;
            };
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}