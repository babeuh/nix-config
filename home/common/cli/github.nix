{ pkgs, ... }: {
  programs.gh = {
    enable = true;
    
    gitCredentialHelper.enable = false;
    settings = {
      git_protocol = "ssh";

      prompt = "enabled";
      editor = "nvim";

      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };

  programs.gh-dash.enable = true;
}
