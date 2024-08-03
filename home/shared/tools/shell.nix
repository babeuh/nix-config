{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop # System viewer
    just # Run project-specific commands.
    minisign # Signatures

    eza # Better ls
    fd # Better find
    fzf # Fuzzy finder
    ripgrep # Better grep
    ripgrep-all # Even better grep
    ripunzip # Better unzip
    zoxide # Better cd
    fend # Better bc

    nixfmt-rfc-style # Nix formatter

    yubikey-manager # Yubikey
    texliveFull
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.bat = {
    enable = true;
    config.theme = "base16";
  };

  programs.zoxide = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      ls = "eza";
      cat = "bat";
      cd = "z";
      unzip = "ripunzip";
      bc = "fend";
    };
    shellAliases = {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      mail = "TERM=xterm-direct neomutt"; # TODO: add to darwin
    };
    functions = {
      fish_greeting = "";
    };
    interactiveShellInit =
      # Open command buffer in vim when alt+e is pressed
      ''
        bind \ee edit_command_buffer
      ''
      + ''
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
      ''
      +
        # Use terminal colors
        ''
          set -U fish_color_autosuggestion      brblack
          set -U fish_color_cancel              -r
          set -U fish_color_command             brgreen
          set -U fish_color_comment             brmagenta
          set -U fish_color_cwd                 green
          set -U fish_color_cwd_root            red
          set -U fish_color_end                 brmagenta
          set -U fish_color_error               brred
          set -U fish_color_escape              brcyan
          set -U fish_color_history_current     --bold
          set -U fish_color_host                normal
          set -U fish_color_match               --background=brblue
          set -U fish_color_normal              normal
          set -U fish_color_operator            cyan
          set -U fish_color_param               brblue
          set -U fish_color_quote               yellow
          set -U fish_color_redirection         bryellow
          set -U fish_color_search_match        'bryellow' '--background=brblack'
          set -U fish_color_selection           'white' '--bold' '--background=brblack'
          set -U fish_color_status              red
          set -U fish_color_user                brgreen
          set -U fish_color_valid_path          --underline
          set -U fish_pager_color_completion    normal
          set -U fish_pager_color_description   yellow
          set -U fish_pager_color_prefix        'white' '--bold' '--underline'
          set -U fish_pager_color_progress      'brwhite' '--background=cyan'
        '';
  };
}
