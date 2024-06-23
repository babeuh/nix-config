{ inputs, outputs, ... }:
let
  helpers = import ./helpers.nix { inherit inputs outputs; };
in
{
  inherit (helpers) mkSystem forAllSystems;
}
