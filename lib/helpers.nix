{ inputs, outputs, ... }:
{
  # Helper function for generating systems
  mkSystem =
    {
      hostname,
      username,
      platform,
      stateVersion,
      desktop ? null,
    }:
    let
      systemFunction =
        if platform == "aarch64-darwin" then
          inputs.nix-darwin.lib.darwinSystem
        else
          inputs.nixpkgs.lib.nixosSystem;

      homeManagerModule =
        if platform == "aarch64-darwin" then
          inputs.home-manager.darwinModules.home-manager
        else
          inputs.home-manager.nixosModules.home-manager;
    in
    systemFunction {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      specialArgs = {
        inherit
          inputs
          outputs
          hostname
          username
          platform
          stateVersion
          desktop
          ;
      };

      modules = [
        ../hosts/shared
        ../hosts/${platform}
        ../hosts/${platform}/${hostname}

        homeManagerModule
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit
              inputs
              outputs
              hostname
              username
              platform
              stateVersion
              desktop
              ;
          };

          home-manager.users.${username} = import ../home/${username};

          home-manager.sharedModules = [
            inputs.arkenfox.hmModules.default
            inputs.nixvim.homeManagerModules.nixvim
            inputs.nix-colors.homeManagerModules.default
            inputs.nur.hmModules.nur

            ../home/shared
            ../home/${platform}
          ] ++ (builtins.attrValues (import ../modules/home-manager));
        }
      ] ++ (builtins.attrValues (import ../modules/nixos));
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
