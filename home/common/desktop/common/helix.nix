{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    languages = {
      language = [
        {
          name = "rust";
          config.checkOnSave.command = "clippy";
        }
      ];
    };
    settings = {
      keys.normal = {
        space.space = "file_picker";
        space.x = ":x";
        space.w = ":w";
        space.q = ":q";
      };
    };
  };
  home.packages = with pkgs; [ rnix-lsp ];
}
