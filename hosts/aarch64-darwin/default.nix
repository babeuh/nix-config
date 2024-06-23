{ pkgs, username, ...}: {
  # Nix configuration
  nix.package = pkgs.nix;
  services.nix-daemon.enable = true;
  environment.systemPackages = [ pkgs.nix ];
  nix.gc.interval = [
    {
      Hour = 3;
      Minute = 0;
      Weekday = 7;
    }
  ];

  # Fix for https://github.com/LnL7/nix-darwin/issues/682
  users.users.${username}.home = "/Users/${username}";
}
