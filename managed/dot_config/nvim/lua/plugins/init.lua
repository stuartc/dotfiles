return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = {
      -- defaults = {
      --   file_ignore_patterns = { "node_modules", ".git/" },
      -- },
      -- pickers = {
      --   find_files = {
      --     hidden = true,
      --   },
      --   live_grep = {
      --     additional_args = { "--hidden" },
      --   },
      -- },
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
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "beancount",
        "typescript", "elixir", "heex"
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
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" }
      })
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Multiple cursors (select word, Ctrl+n for next match)
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
        separator_column = 70,
        instant_alignment = true,
        auto_format_on_save = true,
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
  },

  -- Gitsigns with inline blame
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
    },
  },
}
