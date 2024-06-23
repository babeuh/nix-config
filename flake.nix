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
  };

  outputs = { self, nixpkgs, home-manager, nixos-generators, ... }@inputs:
    let
      inherit (self) outputs;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkHost = hostname: username: (
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs hostname username; };
          modules = [
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.impermanence.nixosModules.impermanence
            inputs.agenix.nixosModules.default
            inputs.nix-ld.nixosModules.nix-ld
            ./hosts/common
            ./hosts/${hostname}

            home-manager.nixosModules.home-manager

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs outputs hostname;
              };
              home-manager.users.${username} = import ./home/${username};
              home-manager.sharedModules = [
                inputs.arkenfox.hmModules.default
                inputs.nixvim.homeManagerModules.nixvim
                inputs.nix-colors.homeManagerModules.default
                inputs.nur.hmModules.nur
                inputs.impermanence.nixosModules.home-manager.impermanence
                ./home/common
              ] ++ (builtins.attrValues (import ./modules/home-manager));
            }
          ];
        }
      );
    in {
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs inputs; }
      );

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlay { inherit inputs; };

      nixosConfigurations = {
        atlas   = mkHost "atlas"   "babeuh";
        iapetus = mkHost "iapetus" "babeuh";
      };

      installer = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "install-iso";
        specialArgs = { inherit inputs; };

        modules = [
          inputs.disko.nixosModules.default

          ./hosts/installer
        ];
      };
    };
}
