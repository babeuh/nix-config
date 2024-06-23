{ outputs, inputs, lib, config, ... }: {
  nixpkgs = {
    overlays = [
      outputs.overlays.modifications
      outputs.overlays.additions
      inputs.arkenfox.overlays.default
    ];
    config.allowUnfree = true;
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };

    # To note, this will gc home-manager user profiles as well
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
