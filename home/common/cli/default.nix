{ pkgs, ... }: {
  imports = [
    ./bash.nix
    ./bat.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./starship.nix
    ./vim.nix
    ./github.nix
    ./mail.nix
    ./browser.nix
    ./cd.nix
    ./music.nix
  ];
  home.packages = with pkgs; [
    bc # Calculator
    btop # System viewer
    ncdu # TUI disk usage

    eza # Better ls
    ripgrep # Better grep
    fd # Better find

    nixfmt-rfc-style # Nix formatter

    yubikey-manager # Yubikey
    texlive.combined.scheme-full 
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.command-not-found.enable = false;
  
  # yubikey-agent
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/yubikey-agent/yubikey-agent.sock";
}
