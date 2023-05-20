{ pkgs, config, ... }: {
  config.fontProfiles = {
    enable = true;
    monospace = {
      family = "CozetteVector";
      package = pkgs.cozette;
    };
    regular = {
      family = "CozetteVector";
      package = pkgs.cozette;
    };
  };
}
