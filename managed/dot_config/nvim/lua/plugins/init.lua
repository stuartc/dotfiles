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
}
