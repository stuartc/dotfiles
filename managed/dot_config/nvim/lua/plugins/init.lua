return {
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

      return opts
    end,
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
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup({
        nextls = { enable = false },
        elixirls = {
          enable = true,
          tag = "v0.30.0",
          settings = elixirls.settings {
            dialyzerEnabled = true,
            enableTestLenses = true,
          },
        },
        projectionist = { enable = true },
      })
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
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
      on_open = function()
        -- vim.cmd("TwilightEnable")
        vim.wo.wrap = true
        vim.wo.linebreak = true
      end,
      on_close = function()
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
      heading = {
        min_width = 80,
        width = "block",
      },
    },
  },
}
