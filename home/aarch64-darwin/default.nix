{
  # FIXME: create nix-darwin module for yubikey-agent
  home.sessionVariables = {
    SSH_AUTH_SOCK = "/opt/homebrew/var/run/yubikey-agent.sock";
    PATH = "$PATH:/opt/homebrew/bin";
  };
}
