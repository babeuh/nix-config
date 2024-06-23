{ inputs, stateVersion, ...}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.impermanence.nixosModules.impermanence
    inputs.agenix.nixosModules.default

    # FIXME: This is temporary till I get around moving old common to shared and platform specific
    ../common
  ];

  system.stateVersion = stateVersion;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
