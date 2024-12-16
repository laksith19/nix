{
  description = "Laksith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    nixos-hardware,
    nix-index-database,
    nixvim,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.quirrel = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/quirrel.nix

        nixos-hardware.nixosModules.lenovo-thinkpad-x13-amd

        nix-index-database.nixosModules.nix-index

        home-manager.nixosModules.default

        stylix.nixosModules.stylix
        nixvim.nixosModules.nixvim
      ];
    };
    formatter.${system} = pkgs.alejandra;
    devShells.${system}.default = pkgs.mkShell {
      shellHook = "alias rebuild='sudo nixos-rebuild switch --flake ./'";
    };
  };
}
