{
  description = "Laksith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixos-hardware,
    nix-index-database,
    nixvim,
    catppuccin,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    rebuild = pkgs.writeShellScriptBin "rebuild" ''
      sudo nixos-rebuild switch --flake ./
    '';
    update = pkgs.writeShellScriptBin "update" ''
      git pull
      nix flake update
      git add .
      git commit -m "chore: update flake"
      git push
    '';
  in {
    nixosConfigurations.quirrel = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/quirrel.nix
        {
          _module.args = {inherit catppuccin;};
        }

        nixos-hardware.nixosModules.lenovo-thinkpad-x13-amd

        nix-index-database.nixosModules.nix-index

        home-manager.nixosModules.default

        nixvim.nixosModules.nixvim

        catppuccin.nixosModules.catppuccin

        home-manager.nixosModules.home-manager
      ];
    };
    formatter.${system} = pkgs.alejandra;
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        update
        rebuild
      ];
    };
  };
}
