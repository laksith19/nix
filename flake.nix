{
  description = "Laksith's NixOS configuration";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    nixos-hardware = {
      type = "github";
      owner = "nixos";
      repo = "nixos-hardware";
      ref = "master";
    };

    nix-index-database = {
      type = "github";
      owner = "nix-community";
      repo = "nix-index-database";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      type = "github";
      owner = "nix-community";
      repo = "nixvim";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      type = "github";
      owner = "catppuccin";
      repo = "nix";
      ref = "main";
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
