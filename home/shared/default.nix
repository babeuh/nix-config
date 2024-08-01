{ stateVersion, username, ... }:
{
  imports = [
    ./tools
    ./messaging
    ./variables.nix
  ];

  home.username = username;
  home.stateVersion = stateVersion;
}
