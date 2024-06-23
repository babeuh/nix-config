{ pkgs, username, ...}: {
  # Nix Configuration
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  services.nix-daemon.enable = true;

  # Fix for https://github.com/LnL7/nix-darwin/issues/682
  users.users.${username}.home = "/Users/${username}";
}
