return {
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      actions = {
        open_file = {
          resize_window = false,
        },
      },
      git = {
        enable = true,
        timeout = 3000,
      },
      filesystem_watchers = {
        enable = true,
        debounce_delay = 200,
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
        -- fd (not rg) so we can --follow into the .context symlink; it respects
        -- each repo's .gitignore, and a per-repo .ignore (!.context) re-includes it.
        find_command = { "fd", "--type", "f", "--hidden", "--follow" },
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
      opts.extensions.smart_open = {
        match_algorithm = "fzf",
        cwd_only = true,
        filename_first = true,
        path_display = { "filename_first" },
        previewer = true,
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            prompt_position = "top",
          },
        },
      }

      return opts
    end,
  },

  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    dependencies = {
      "kkharji/sqlite.lua",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").load_extension("smart_open")
      require("telescope").load_extension("fzf")
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

  -- mason-lspconfig: installs LSP servers from configs/tools.lua (lsp list),
  -- translating lspconfig names → Mason package names. Pair with
  -- vim.lsp.enable in configs/lspconfig.lua, which reads the same list.
  --
  -- automatic_enable is disabled because its default (true) silently calls
  -- vim.lsp.enable() for every Mason-installed package — not just those in
  -- ensure_installed — bypassing tools.lua as the source of truth.
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = function()
      return {
        ensure_installed = require("configs.tools").lsp,
        automatic_installation = false,
        automatic_enable = false,
      }
    end,
  },

  -- mason-tool-installer: installs non-LSP tools (formatters, linters, DAP)
  -- from configs/tools.lua (extras list), using Mason package names directly.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = function()
      return {
        ensure_installed = require("configs.tools").extras,
        run_on_start = true,
        auto_update = false,
      }
    end,
  },

  -- blink.cmp completion engine
  { import = "nvchad.blink.lazyspec" },

  -- Project-wordlist completion via blink's existing buffer source.
  -- If the cwd contains a `.nvim-dict.txt`, its lines are loaded into a
  -- hidden buffer and fed through the buffer source — so a project's domain
  -- vocabulary completes everywhere, not just from currently-open buffers.
  -- Inert by default: projects without the file behave exactly as before.
  -- (Generate the wordlist however suits the project, e.g. a Taskfile target.)
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          buffer = {
            -- Sentence starts: typing a capital offers the capitalised form of
            -- lowercase candidates. Never the reverse — downcasing to match a
            -- lowercase prefix would wreck OpenFn, Thunderbolt and every
            -- camelCase identifier in the wordlist. Both `label` and
            -- `insertText` must be set; `label` alone only changes the menu.
            -- Runs once per completion session (the buffer source reports
            -- complete, so blink caches), which is fine: only the first typed
            -- character is ever inspected.
            transform_items = function(ctx, items)
              if not ctx.get_keyword():sub(1, 1):match("%u") then
                return items
              end

              -- Words already offered in a mixed-case spelling: "openfn" is
              -- left alone when "OpenFn" is on the menu, rather than becoming
              -- "Openfn". Only a capital past the first character counts —
              -- "Headphones" is just a sentence start, not a spelling.
              local canonical = {}
              for _, item in ipairs(items) do
                local word = item.insertText or item.label
                if word and word:sub(2):find("%u") then
                  canonical[word:lower()] = true
                end
              end

              local seen, out = {}, {}
              for _, item in ipairs(items) do
                local word = item.insertText or item.label
                -- Anything carrying an internal capital is an identifier, not
                -- prose: accountId must not become AccountId.
                if
                  word
                  and word:match("^%l")
                  and not word:find("%u")
                  and not canonical[word:lower()]
                then
                  word = word:sub(1, 1):upper() .. word:sub(2)
                  item.insertText, item.label = word, word
                end
                -- Capitalising can collide with an entry that was already
                -- capitalised, so drop the repeats.
                if not word or not seen[word] then
                  if word then
                    seen[word] = true
                  end
                  out[#out + 1] = item
                end
              end
              return out
            end,
            opts = {
              get_bufnrs = function()
                -- All "normal" buffers (NvChad default is visible-only)...
                local bufs = vim.tbl_filter(function(b)
                  return vim.bo[b].buftype == ""
                end, vim.api.nvim_list_bufs())

                -- ...plus the project wordlist, if one exists in the cwd.
                local dict = vim.fn.getcwd() .. "/.nvim-dict.txt"
                if vim.fn.filereadable(dict) == 1 then
                  local bufnr = vim.fn.bufnr(dict)
                  if bufnr == -1 then
                    bufnr = vim.fn.bufadd(dict)
                    vim.fn.bufload(bufnr)
                    vim.bo[bufnr].buflisted = false
                  end
                  table.insert(bufs, bufnr)
                end

                return bufs
              end,
            },
          },
        },
      },
    },
  },

  -- nvim-treesitter `main` branch: no .configs.setup(), no ensure_installed
  -- in opts. Install via Lua API, enable highlight+indent via FileType
  -- autocmd. Parser list lives in configs/tools.lua. Note: `config` here
  -- also overrides NvChad's master-branch setup() call which would error.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    priority = 50,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(require("configs.tools").parsers or {})

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if pcall(vim.treesitter.start, args.buf, lang) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
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
    opts = {
      surrounds = {
        -- `c` for codefence: wraps in triple backticks (e.g. Sc in visual-line mode)
        ["c"] = {
          add = { "```", "```" },
          find = "```.-```",
          delete = "^(```)().-(```)()$",
        },
      },
      -- Markdown-specific surrounds (bold `b`, strikethrough `s`) live in
      -- after/ftplugin/markdown.lua via nvim-surround's buffer_setup.
    },
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
    config = function()
      -- Workaround for coder/claudecode.nvim#166: the keepalive timer (30s) tears
      -- down an idle client via two close paths; the async write callback in
      -- close_client hits an unguarded tcp_handle:close(), so libuv throws
      -- "handle is already closing" ~30s into edit mode. Guard the close like
      -- tcp.lua already does. Remove once #166 merges upstream.
      local client = require("claudecode.server.client")
      local frame = require("claudecode.server.frame")
      function client.close_client(c, code, reason)
        if c.state == "closed" or c.state == "closing" then
          return
        end
        c.state = "closing"
        local function safe_close()
          c.state = "closed"
          if c.tcp_handle and not c.tcp_handle:is_closing() then
            c.tcp_handle:close()
          end
        end
        if c.handshake_complete then
          c.tcp_handle:write(frame.create_close_frame(code or 1000, reason or ""), safe_close)
        else
          safe_close()
        end
      end

      require("claudecode").setup({
        auto_start = true,  -- Start WebSocket server when Neovim launches
        terminal = {
          provider = "none",  -- Disable Neovim terminal; use external terminal (iTerm2, tmux)
        },
      })
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
    init = function()
      local apply = function()
        local link = function(from, to)
          vim.api.nvim_set_hl(0, from, { link = to })
        end
        link("NeogitDiffAdd",              "DiffAdd")
        link("NeogitDiffAddHighlight",     "DiffAdd")
        link("NeogitDiffAddCursor",        "DiffAdd")
        link("NeogitDiffDelete",           "DiffDelete")
        link("NeogitDiffDeleteHighlight",  "DiffDelete")
        link("NeogitDiffDeleteCursor",     "DiffDelete")
        link("NeogitDiffContext",          "Normal")
        link("NeogitDiffContextHighlight", "CursorLine")
        link("NeogitDiffContextCursor",    "CursorLine")
        link("NeogitHunkHeader",           "DiffChange")
        link("NeogitHunkHeaderHighlight",  "DiffChange")
        link("NeogitHunkHeaderCursor",     "DiffChange")
      end
      apply()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
    end,
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

  -- Git worktrees (create/switch/remove, snacks picker frontend)
  {
    "Juksuu/worktrees.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "GitWorktreeCreate", "GitWorktreeCreateExisting", "GitWorktreeSwitch", "GitWorktreeRemove" },
    keys = {
      { "<leader>gws", function() Snacks.picker.worktrees() end, desc = "Git worktree switch" },
      { "<leader>gwn", function() Snacks.picker.worktrees_new() end, desc = "Git worktree new" },
      { "<leader>gwr", function() Snacks.picker.worktrees_remove() end, desc = "Git worktree remove" },
    },
    opts = {
      -- Grouped as <project>/<branch> here; the default ("..") drops bare branch
      -- names alongside the repo, i.e. straight into $PROJECTS.
      worktree_path = "~/Sourcecode/.worktrees",
      hooks = {
        on_before_switch = function()
          -- root_dir is fixed when a client attaches, so clients started in the
          -- old worktree keep resolving paths there after the cwd moves.
          vim.lsp.stop_client(vim.lsp.get_clients())
        end,
        on_switch = function(_, to)
          pcall(function()
            require("nvim-tree.api").tree.change_root(to)
          end)
        end,
      },
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

  -- Focus mode (center buffer with side padding)
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    cmd = "NoNeckPain",
    keys = {
      { "<leader>z", "<cmd>NoNeckPain<cr>", desc = "Focus Mode" },
    },
    opts = {
      width = 80,
      autocmds = {
        skipEnteringNoNeckPainBuffer = true,
      },
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
