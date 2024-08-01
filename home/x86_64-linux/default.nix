{ inputs, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence

    # FIXME: This is temporary till I get around moving old common to shared and platform specific
    ../common
  ];
}
