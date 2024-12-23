{ pkgs, ... }:
{
  home.sessionVariables.EDITOR = "nvim";
  programs.fish.shellAliases = {
    vim = "nvim";
    vimdiff = "nvim -d";
  };
  programs.nixvim = {
    enable = true;
    /*
      colorschemes.base16 = {
        enable = true;
        colorscheme = config.colorscheme.slug; FIXME: add colorschemes to darwin
      };
    */

    opts = {
      number = true;

      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 0;
      autoindent = true;
      smarttab = true;

      foldcolumn = "2";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };
    extraPlugins = [ pkgs.vimPlugins.limelight-vim ];
    extraConfigLuaPre = ''
      vim.g.coq_settings = { clients = { buffers = { enabled = false, }, } }
    '';
    extraFiles = {
      "plugin/nvim-ufo.lua".text = ''
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
        }
        local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
        for _, ls in ipairs(language_servers) do
            require('lspconfig')[ls].setup({
                capabilities = capabilities
                -- you can add other fields for setting up lsp server in this table
            })
        end
      '';
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>f";
        options.silent = true;
        action = ":Neotree toggle<CR>";
      }
      {
        mode = "n";
        key = "zR";
        options.silent = true;
        action.__raw = "require('ufo').openAllFolds";
      }
      {
        mode = "n";
        key = "zM";
        options.silent = true;
        action.__raw = "require('ufo').closeAllFolds";
      }
      {
        mode = "n";
        key = "<leader>t";
        options.silent = true;
        action = ":ToggleTerm direction=float<CR>";
      }
      {
        mode = "n";
        key = "<leader><leader>g";
        options.silent = true;
        action = ":Goyo<CR>:Limelight!!<CR>:set noshowmode!<CR>:set noshowcmd!<CR>:set linebreak!<CR>";
      }
      {
        mode = "t";
        key = "<esc><esc>";
        options.silent = true;
        options.noremap = true;
        action = "<C-\\><C-n>:ToggleTerm<CR>";
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
      {
        mode = "n";
        key = "<leader>ff";
        options.silent = true;
        action = ":Telescope fd<CR>";
      }
      {
        mode = "n";
        key = "<leader>ft";
        options.silent = true;
        action = ":Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>fgc";
        options.silent = true;
        action = ":Telescope git_commits<CR>";
      }
      {
        mode = "n";
        key = "<leader>fgb";
        options.silent = true;
        action = ":Telescope git_branches<CR>";
      }
      {
        mode = "n";
        key = "<leader>fgs";
        options.silent = true;
        action = ":Telescope git_status<CR>";
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

        settings = {
          incremental_selection.enable = true;
          ensure_installed = [
            # required
            "c"
            "lua"
            "vim"
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
          indent.enable = true;
        };
      };
      vimtex.enable = true;
      neorg = {
        enable = false; # Waiting on https://github.com/NixOS/nixpkgs/pull/302442
        modules = {
          "core.defaults" = { };
          "core.integrations.image" = { };
          "core.latex.renderer" = { };
          "core.concealer" = {
            config = {
              icon_preset = "diamond";
            };
          };
          "core.dirman" = {
            config = {
              workspaces = {
                notes = "~/notes";
              };
            };
          };
        };
      };

      # Utility
      treesitter-textobjects = {
        enable = true;
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            # Parameters
            "aa" = {
              query = "@parameter.outer";
              desc = "Select outer part of a parameter region";
            };
            "ia" = {
              query = "@parameter.inner";
              desc = "Select inner part of a parameter region";
            };
            # Functions
            "af" = {
              query = "@function.outer";
              desc = "Select outer part of a function region";
            };
            "if" = {
              query = "@function.inner";
              desc = "Select inner part of a function region";
            };
            # Classees
            "ac" = {
              query = "@class.inner";
              desc = "Select outer part of a class region";
            };
            "ic" = {
              query = "@class.inner";
              desc = "Select inner part of a class region";
            };
            # Conditionals
            "ai" = {
              query = "@conditional.outer";
              desc = "Select outer part of a conditional region";
            };
            "ii" = {
              query = "@conditional.inner";
              desc = "Select inner part of a conditional region";
            };
            # Loops
            "al" = {
              query = "@loop.outer";
              desc = "Select outer part of a loop region";
            };
            "il" = {
              query = "@loop.inner";
              desc = "Select inner part of a loop region";
            };
            # Comments
            "it" = {
              query = "@comment.outer";
              desc = "Select outer part of a comment region";
            };
            # Assignments
            "ak" = {
              query = "@assignment.lhs";
              desc = "Select key of a assignment region";
            };
            "ik" = {
              query = "@assignment.rhs";
              desc = "Select value of a assignment region";
            };
          };
        };
        move = {
          enable = true;
          gotoNextStart = {
            "]m" = "@function.outer";
            "]]" = "@class.outer";
          };
          gotoNextEnd = {
            "]M" = "@function.outer";
            "][" = "@class.outer";
          };
          gotoPreviousStart = {
            "[m" = "@function.outer";
            "[]" = "@class.outer";
          };
          gotoPreviousEnd = {
            "[M" = "@function.outer";
            "[[" = "@class.outer";
          };
        };
        swap = {
          enable = true;
          swapNext = {
            "<leader>a" = "@parameters.inner";
          };
          swapPrevious = {
            "<leader>A" = "@parameter.outer";
          };
        };
      };
      nvim-autopairs = {
        enable = true;
        settings.check_ts = true;
      };
      ts-autotag.enable = true;
      telescope.enable = true;
      nvim-colorizer = {
        enable = true;
        fileTypes = [ "css" ];
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
      surround.enable = true;

      # UI
      gitsigns = {
        enable = true;
        settings = {
          show_deleted = true;
          current_line_blame = true;
        };
      };
      git-conflict.enable = true;
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
      };
      dashboard = {
        enable = true;
        settings = {
          theme = "hyper";
          config.week_header.enable = true;
          hide = {
            statusline = true;
            tabline = true;
          };
        };
      };
      toggleterm.enable = true;
      nvim-ufo.enable = true;
      goyo.enable = true;

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
          {
            shortName = "vTex";
            src = "vimtex";
          }
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
