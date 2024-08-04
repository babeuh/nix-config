{
  inputs,
  pkgs,
  username,
  ...
}:
{
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
  nixpkgs.overlays = [ inputs.nix-darwin.overlays.default ];

  # Shell stuff
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  users.users.${username} = {
    # Fix for https://github.com/LnL7/nix-darwin/issues/682
    home = "/Users/${username}";
    # Shell
    shell = pkgs.fish;
  };

  system.defaults = {
    NSGlobalDomain = {
      # Metric Units
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      # Style
      AppleInterfaceStyle = "Dark";
      AppleShowScrollBars = "WhenScrolling";
      # Usability
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      _HIHideMenuBar = true;
    };
    dock = {
      autohide = true;
      "autohide-delay" = 2.0;
      "show-recents" = false;
      showhidden = true;
      "static-only" = true;
    };
    finder.ShowPathbar = true;
  };
  system.startup.chime = false;

  # Touch ID for sudo.
  security.pam.enableSudoTouchIdAuth = true;
}
