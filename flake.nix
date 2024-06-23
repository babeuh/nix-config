{
  description = "nix-config";

  inputs = {
    #
    # Shared inputs
    #

    # Packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    # User profile manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declartive theming
    nix-colors.url = "github:misterio77/nix-colors";

    # Firefox hardening
    arkenfox = {
        url = "github:dwarfmaster/arkenfox-nixos";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declartive vim config
    nixvim = {
        url = "github:pta2002/nixvim";
        inputs.nixpkgs.follows = "nixpkgs";
    };


    #
    # NixOS-specific inputs
    #

    # Secure Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Links persistent folders into system
    impermanence.url = "github:babeuh/impermanence";

    # Provides module support for specific vendor hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Secrets using age
    agenix = {
      url = "github:babeuh/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Window manager
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    # NixOS image builder
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declartive disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    #
    # Darwin-specific inputs
    #

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }@inputs:
    let
      inherit (self) outputs;
      libx = import ./lib { inherit inputs outputs; };
    in {
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs inputs; }
      );

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlay { inherit inputs; };

      nixosConfigurations = {
        # FIXME: Hyprland is broken so temporarily using GNOME
        atlas = libx.mkSystem { hostname = "atlas"; username = "babeuh"; platform = "x86_64-linux"; stateVersion = "23.05"; desktop = "gnome"; };
      };

      darwinConfigurations = {
        "Macbook-Air" = libx.mkSystem { hostname = "Macbook-Air"; username = "raphael"; platform = "aarch64-darwin"; stateVersion = "24.05"; desktop = "darwin"; };
      };

      /* TODO: THIS SHOULD BE REWORKED
      installer = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "install-iso";
        specialArgs = { inherit inputs; };

        modules = [
          inputs.disko.nixosModules.default

          ./hosts/installer
        ];
      };*/
    };
}
