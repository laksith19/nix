{
  description = "Laksith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    stylix,
    nixos-hardware,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
  in {
    nixosConfigurations.quirrel = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit pkgs-unstable;};
      modules = [
        ./nixos/configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-x13-amd
        home-manager.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.laksith = import ./homes/laksith.nix;
        }
        stylix.nixosModules.stylix
      ];
    };
    formatter.${system} = pkgs.alejandra;
    devShells.${system}.default = pkgs.mkShell {
      shellHook = "alias rebuild='sudo nixos-rebuild switch --flake ./'";
    };
  };
}
