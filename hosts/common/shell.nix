{ pkgs, ... }: {
  # TODO: Consider moving to nushell or other rust shells, check that github issue IDK
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];
}
