# When you add custom packages, list them here
# These are similar to nixpkgs packages
{ pkgs ? (import ../nixpkgs.nix) { } }: {
  # pkg = pkgs.callPackage ./pkg.nix { };
}
