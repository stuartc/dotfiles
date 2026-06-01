-- smart-splits.nvim: seamless <C-hjkl> navigation and resize across the
-- nvim-split / tmux-pane boundary.
--
-- lazy = false is REQUIRED. The tmux integration works by the plugin setting
-- the `@pane-is-vim` pane option on load (and clearing it on exit/suspend);
-- the tmux-side guard in tmux.conf reads that option to decide whether to pass
-- C-hjkl through to nvim or move tmux panes itself. Lazy-loading would leave
-- @pane-is-vim unset and break the guard.
--
-- Navigation: <C-h/j/k/l> move between nvim splits and cross into adjacent
-- tmux panes at the layout edge. The nav keymaps are defined in mappings.lua
-- (after `require "nvchad.mappings"`) rather than via this spec's `keys`,
-- because NvChad's default <C-hjkl> = <C-w>hjkl window maps load *after* lazy's
-- key handler and would otherwise clobber them. Harpoon file-jumps, which
-- previously owned <C-hjkl>, now live on <leader>1-4 (see mappings.lua).
--
-- Resize: <leader>rr enters a resize submode (submode.nvim) where bare hjkl
-- grow/shrink the active split, handing off to `tmux resize-pane` at the edge.
-- <Esc>, q, or <C-c> leave the mode. Steps are default_amount columns/rows.
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- LOAD-BEARING: do NOT add event/keys/cmd here. Lazy-loading
                -- leaves @pane-is-vim unset, so tmux silently steals C-hjkl.

  dependencies = { "pogyomo/submode.nvim" },
  opts = {
    -- 'stop' at the true outermost edge (no wrap). Moves at an *inner* nvim
    -- edge still hand off to adjacent tmux panes via the integration below.
    at_edge = "stop",
    multiplexer_integration = "tmux",
    default_amount = 3,
    -- ignored_filetypes defaults to { "NvimTree" }, which matches our tree.
  },
  -- Nav keymaps (<C-hjkl>) live in mappings.lua so they load after
  -- nvchad.mappings and win over NvChad's default <C-w> window maps.
  config = function(_, opts)
    local ss = require("smart-splits")
    ss.setup(opts)

    -- Persistent resize mode: <leader>rr, then bare hjkl until <Esc>/q/<C-c>.
    -- (<leader>r is a live prefix — ra/rn/rt — hence the doubled key.)
    require("submode").create("WinResize", {
      mode = "n",
      enter = "<leader>rr",
      leave = { "<Esc>", "q", "<C-c>" },
      default = function(register)
        register("h", function() ss.resize_left() end, { desc = "Resize left" })
        register("j", function() ss.resize_down() end, { desc = "Resize down" })
        register("k", function() ss.resize_up() end, { desc = "Resize up" })
        register("l", function() ss.resize_right() end, { desc = "Resize right" })
      end,
    })
  end,
}
