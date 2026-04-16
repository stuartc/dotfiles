return {
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      actions = {
        open_file = {
          resize_window = false,
        },
      },
      renderer = {
        highlight_git = "name",
        icons = {
          git_placement = "after",
          glyphs = {
            git = {
              unstaged = "\u{f459}",  -- nf-oct-diff_modified
              staged = "\u{f457}",    -- nf-oct-diff_added
              unmerged = "\u{f47f}",  -- nf-oct-git_compare
              renamed = "\u{f45a}",   -- nf-oct-diff_renamed
              untracked = "\u{f420}", -- nf-oct-question
              deleted = "\u{f458}",   -- nf-oct-diff_removed
              ignored = "\u{f474}",   -- nf-oct-diff_ignored
            },
          },
        },
      },
    },
    init = function()
      -- Git icon colors from active base46 theme
      local colors = require("base46").get_theme_tb "base_30"
      vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "NvimTreeGitStagedIcon", { fg = colors.green })
      vim.api.nvim_set_hl(0, "NvimTreeGitMergeIcon", { fg = colors.red })
      vim.api.nvim_set_hl(0, "NvimTreeGitRenamedIcon", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "NvimTreeGitNewIcon", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "NvimTreeGitDeletedIcon", { fg = colors.red })
      vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", { fg = colors.light_grey })
    end,
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local open_external = function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection and selection.path then
          require("utils").open_external(selection.path)
        end
      end

      opts.defaults = opts.defaults or {}
      opts.defaults.mappings = opts.defaults.mappings or {}
      opts.defaults.mappings.i = opts.defaults.mappings.i or {}
      opts.defaults.mappings.n = opts.defaults.mappings.n or {}
      opts.defaults.mappings.i["<C-o>"] = open_external
      opts.defaults.mappings.n["<C-o>"] = open_external

      opts.pickers = opts.pickers or {}
      opts.pickers.find_files = {
        -- find_command = { "rg", "--files", "--hidden", "--follow", "--glob", "!.git" },
        path_display = { "filename_first" },
        previewer = true,
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            prompt_position = "top",
        --     width = 80,
        --     height = 20,
          },
        },
      }

      opts.extensions = opts.extensions or {}
      opts.extensions.frecency = {
        db_safe_mode = false,
        default_workspace = "CWD",
        show_unindexed = true,
        show_filter_column = false,
        matcher = "fuzzy",
        path_display = { "filename_first" },
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            prompt_position = "top",
          },
        },
        previewer = true,
      }

      return opts
    end,
  },

  {
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require("telescope").load_extension("frecency")
    end,
  },

  -- NvimTree window picker: exclude special buffers so files open
  -- in the last focused editor window instead of prompting "Pick window:"
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      actions = {
        open_file = {
          window_picker = {
            enable = true,
            exclude = {
              filetype = {
                "NvimTree",
                "NeogitStatus",
                "NeogitPopup",
                "NeogitLogView",
                "NeogitConsole",
                "DiffviewFiles",
                "DiffviewFileHistory",
                "diff",
                "qf",
                "lazy",
                "mason",
              },
              buftype = {
                "terminal",
                "help",
                "prompt",
                "quickfix",
              },
            },
          },
        },
      },
    },
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- blink.cmp completion engine
  { import = "nvchad.blink.lazyspec" },

  -- Add beancount source to blink.cmp
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}
      table.insert(opts.sources.default, "beancount")
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.beancount = {
        name = "beancount",
        module = "beancount.completion.blink",
        score_offset = 100,
        opts = {
          trigger_characters = { ":", "#", "^", '"', " " },
        },
      }
      return opts
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    priority = 50,
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "beancount",
        "typescript", "elixir", "heex",
        "markdown", "markdown_inline",
      },
    },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Multiple cursors (<C-n> select word, then next match)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
  },

  -- Claude Code IDE integration (external terminal via lock file discovery)
  {
    "coder/claudecode.nvim",
    event = "VeryLazy",  -- Load at startup for auto_start
    keys = {
      { "<leader>cs", mode = "v", "<cmd>ClaudeCodeSend<cr>", desc = "Claude send selection" },
    },
    opts = {
      auto_start = true,  -- Start WebSocket server when Neovim launches
      terminal = {
        provider = "none",  -- Disable Neovim terminal; use external terminal (iTerm2, tmux)
      },
    },
  },

  {
    "hxueh/beancount.nvim",
    ft = { "beancount" },
    opts = function()
      local defaults = {
        python_path = "~/.local/share/uv/tools/beancount/bin/python",
        separator_column = 65,
        instant_alignment = true,
        auto_format_on_save = false,
        auto_fill_amounts = false,
        inlay_hints = true,
        snippets = {
          enabled = true,
          date_format = "%Y-%m-%d",
        },
      }
      -- Merge with project-local overrides from vim.g.beancount_opts
      return vim.tbl_deep_extend("force", defaults, vim.g.beancount_opts or {})
    end,
  },

  -- {
  --   "windwp/nvim-autopairs",
  --   config = function()
  --     local npairs = require("nvim-autopairs")
  --     local Rule = require("nvim-autopairs.rule")
  --     local cond = require("nvim-autopairs.conds")
  --
  --     npairs.setup({})
  --
  --     -- Remove default backtick rule and add one that won't pair after a backtick
  --     npairs.remove_rule("`")
  --     npairs.add_rule(Rule("`", "`"):with_pair(cond.not_before_regex("``", 2)))
  --   end,
  -- },

  -- Neogit (magit-style git workflow)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    opts = {
      integrations = {
        diffview = true,
        telescope = true,
      },
    },
  },

  -- Diffview (PR diff review, file history)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {
      hooks = {
        view_opened = function(view)
          vim.keymap.set("n", "q", "<cmd>DiffviewClose<cr>", { buffer = view.panel.bufnr, desc = "Close Diffview" })
        end,
        diff_buf_read = function(bufnr)
          vim.keymap.set("n", "q", "<cmd>DiffviewClose<cr>", { buffer = bufnr, desc = "Close Diffview" })
        end,
      },
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
      },
    },
  },

  -- Gitsigns with inline blame and hunk keymaps
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation (]c/[c matches vim's diff navigation)
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, { desc = "Next hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, { desc = "Previous hunk" })

        -- Staging and resetting hunks
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage selection" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset selection" })

        -- Buffer-wide operations
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })

        -- Undo staging
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })

        -- Preview
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })

        -- Text object for hunks (select inner hunk)
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
      end,
    },
  },

  -- Snacks.nvim (command palette via picker)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
    },
    keys = {
      { "<leader>p", function() require("command-palette").show() end, desc = "Command Palette" },
    },
  },

  -- Zen Mode (distraction-free writing)
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
    opts = {
      window = {
        backdrop = 0.95,
        width = 80,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        twilight = { enabled = false },
        gitsigns = { enabled = false },
        tmux = { enabled = false },
      },
      on_open = function(win)
        -- vim.cmd("TwilightEnable")
        vim.wo.wrap = true
        vim.wo.linebreak = true
        -- Workaround for folke/zen-mode.nvim#95: re-apply window options on
        -- buffer switch and sync parent window's buffer (mirrors PR #99).
        local view = require("zen-mode.view")
        local grp = vim.api.nvim_create_augroup("ZenModeBufSync", { clear = true })
        vim.api.nvim_create_autocmd("BufEnter", {
          group = grp,
          callback = function()
            if not view.is_open() then return end
            if vim.api.nvim_get_current_win() ~= view.win then return end
            if view.parent and vim.api.nvim_win_is_valid(view.parent) then
              vim.api.nvim_win_set_buf(view.parent, vim.api.nvim_get_current_buf())
            end
            for k, v in pairs(view.opts.window.options or {}) do
              vim.api.nvim_win_set_option(view.win, k, v)
            end
          end,
        })
      end,
      on_close = function()
        pcall(vim.api.nvim_del_augroup_by_name, "ZenModeBufSync")
        vim.cmd("TwilightDisable")
        vim.wo.wrap = false
        vim.wo.linebreak = false
      end,
    },
  },

  -- Twilight (dim inactive code)
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
    opts = {
      dimming = { alpha = 0.25 },
      context = 10,
      treesitter = true,
      expand = { "function", "method", "table", "if_statement" },
    },
  },

  -- Render Markdown (rich markdown preview in buffer)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        -- icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        min_width = 80,
        width = "block",
      },
      bullet = {
        -- icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        -- unchecked = { icon = "󰄱 " },
        -- checked = { icon = "󰱒 " },
      },
      code = {
        style = "full",
        border = "thin",
        width = "block",
        min_width = 80,
      },
      dash = {
        width = 80,
      },
      pipe_table = {
        preset = 'round',
        cell = 'padded',
        min_width = 20,
        border_virtual = true,
        style = 'full',
      },
    },
  },
}
