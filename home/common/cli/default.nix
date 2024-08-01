{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./gpg.nix
    ./starship.nix
    ./github.nix
    ./mail.nix
    ./browser.nix
    ./cd.nix
    ./music.nix
  ];
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/yubikey-agent/yubikey-agent.sock";
  };
}
