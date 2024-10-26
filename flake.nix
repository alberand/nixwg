{
  description = "Homelab Outpost";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    lib = nixpkgs.lib;
  in {
    nixosModules.vpn-server = (import ./vpn-server.nix);

    nixosModules.vpn-client = (import ./vpn-client.nix) {
      inherit pkgs lib;
      ip = "10.100.0.2";
      publicKey = builtins.readFile ./secrets/client.pub;
    };

    nixosConfigurations."vpn-server" = lib.nixosSystem {
      inherit system pkgs;
      modules = [
        agenix.nixosModules.default
        ({config, pkgs, ...}: {
          age.secrets.cliprivate.file = ./secrets/client.private.age;
          age.secrets.srvprivate.file = ./secrets/server.private.age;
          boot.isContainer = true;
          services.openssh.enable = true;
          system.stateVersion = "24.05";
        })
        ({config, pkgs, ...}: self.nixosModules.vpn-server {
          inherit pkgs config;
          peers = [
            {
              publicKey = builtins.readFile ./secrets/client.pub;
              allowedIPs = ["10.100.0.2/32"];
            }
          ];
        })
      ];
    };
  };
}
