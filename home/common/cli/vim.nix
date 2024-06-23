{ config, ... }: {
  home.sessionVariables.EDITOR = "nvim";
  programs.fish.shellAliases = {
    vim = "nvim";
    vimdiff = "nvim -d";
  };
  programs.nixvim = {
    enable = true;
    colorschemes.base16 = {
      enable = true;
      colorscheme = config.colorscheme.slug;
    };

    opts = {
      number = true;

      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 0;
      autoindent = true;
      smarttab = true;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>t";
        options.silent = true;
        action = ":Neotree toggle<CR>";
      }
      {
        mode = "n";
        key = "<leader>g";
        options.silent = true;
        action = ":Neotree toggle float git_status<CR>";
      }
      {
        mode = "n";
        key = "<leader>n";
        options.silent = true;
        action = ":wincmd h<CR>";
      }
      {
        mode = "n";
        key = "<leader>e";
        options.silent = true;
        action = ":wincmd j<CR>";
      }
      {
        mode = "n";
        key = "<leader>i";
        options.silent = true;
        action = ":wincmd k<CR>";
      }
      {
        mode = "n";
        key = "<leader>o";
        options.silent = true;
        action = ":wincmd l<CR>";
      }
    ];

    globals = {
      mapleader = " ";
    };

    plugins = {
      # Languages
      treesitter = {
        enable = true;

        nixGrammars = true;
        ensureInstalled = [
          # required
          "c"
          "lua"
          "vim"
          "help"
          "query"

          # languages
          "nix"
          "markdown"
          "markdown_inline"
          "javascript"
          "typescript"
          "tsx"
          "css"
          "json5"
          "bash"
          "latex"

          # git
          "diff"
          "git_rebase"
          "gitcommit"
          "gitignore"
        ];
        indent = true;
        incrementalSelection.enable = true;
      };
      vimtex.enable = true;

      # Utility
      nvim-autopairs = {
        enable = true;
        settings.check_ts = true;
      };
      ts-autotag.enable = true;
      nvim-colorizer = {
        enable = true;
        fileTypes = [
          "css"
        ];
        userDefaultOptions = {
          sass.enable = true;
          tailwind = "both";
        };
      };
      which-key.enable = true;
      comment = {
        enable = true;
        settings = {
          padding = true;
        };
      };

      # UI
      gitsigns = {
        enable = true;
        settings = {
          show_deleted = true;
          current_line_blame = true;
        };
      };
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
      };
      dashboard = {
        enable = true;
        settings.hide = {
          statusline = true;
          tabline = true;
        };
      };


      # Autocomplete
      coq-nvim = {
        enable = true;
        installArtifacts = true;
        settings = {
          auto_start = true;
        };
      };
      coq-thirdparty = {
        enable = true;
        sources = [
          { shortName = "vTex"; src = "vimtex"; }
        ];
      };
      # LSP
      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            K = "hover";
            gD = "references";
            gd = "definition";
            gi = "implementation";
            gt = "type_definition";
          };
          silent = true;
        };

        servers = {
          nixd.enable = true;
          tailwindcss.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          tsserver.enable = true;
          eslint.enable = true;
        };
      };
      lsp-lines.enable = true;
      lspsaga.enable = true;
    };
  };
}
