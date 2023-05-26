# Shell for bootstrapping flake-enabled nix and home-manager
# Enter through 'nix develop' or (legacy) 'nix-shell'

{ pkgs ? (import ./nixpkgs.nix) {}, inputs }: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git

      inputs.agenix.packages.x86_64-linux.default
      age-plugin-yubikey
      yubikey-agent
      pam_u2f
      sbctl
    ];
  };
}
