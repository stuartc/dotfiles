require "nvchad.mappings"

-- Remove NvChad defaults that are too easy to hit accidentally
vim.keymap.del("n", "<leader>n")

-- ============================================================================
-- Keybindings Reference (leader = Space)
-- ============================================================================
--
-- TELESCOPE (Fuzzy Finding)
--   <leader>ff    Find files
--   <leader>fw    Find word (live grep)
--   <leader>fW    Resume last search (custom)
--   <leader>fb    Find buffers
--   <leader>fo    Find oldfiles (recent)
--   <leader>fz    Find in current buffer
--   <leader>gt    Git status
--   <leader>cm    Git commits
--   <leader>th    Pick theme
--   <C-q>         (in picker) Send results to quickfix list
--
-- QUICKFIX (after <C-q> from Telescope)
--   :copen        Open quickfix window
--   :cnext / ]q   Next item
--   :cprev / [q   Previous item
--
-- PROJECT-WIDE SEARCH & REPLACE (Telescope + Quickfix)
--   <leader>fw    Live grep for pattern
--   <C-q>         Send results to quickfix
--   :cdo s/old/new/gc   Replace in all matches (c = confirm each)
--   :cfdo update  Save all changed files
--
-- TERMINAL
--   <A-h>         Toggle horizontal terminal
--   <A-v>         Toggle vertical terminal
--   <A-i>         Toggle floating terminal
--   <Esc><Esc>    Exit terminal mode to normal mode (custom)
--
-- FILE TREE (nvim-tree)
--   <C-n>         Toggle file tree
--   <leader>e     Focus file tree
--
-- BUFFERS & TABS
--   <Tab>         Next buffer
--   <S-Tab>       Previous buffer
--   <leader>x     Close buffer
--   <leader>bo    Close hidden buffers (custom)
--
-- LSP (when attached) - NvChad mappings
--   gd            Go to definition
--   gD            Go to declaration
--   K             Hover info
--   <leader>ra    Rename symbol
--   <leader>D     Type definition
--   <leader>fm    Format file
--
-- LSP (Neovim 0.10+ built-ins, gr prefix)
--   grr           Find references
--   gra           Code action
--   grn           Rename
--   gri           Go to implementation
--   <leader>rt    Run test codelens (custom)
--
-- HARPOON (custom)
--   <leader>a     Add file to harpoon
--   <C-e>         Toggle harpoon menu
--   <C-h/j/k/l>   Jump to harpoon file 1/2/3/4
--
-- SURROUND (nvim-surround)
--   ys{motion}{char}  Add surround (e.g. ysiw" surrounds word with ")
--   yss{char}         Surround entire line
--   ds{char}          Delete surround (e.g. ds" deletes surrounding ")
--   cs{old}{new}      Change surround (e.g. cs"' changes " to ')
--   dst               Delete surrounding HTML tag
--   cst<tag>          Change surrounding tag (e.g. cst<div>)
--   S{char}           Surround selection (visual mode)
--
-- MACROS
--   <leader>ma    Apply macro 'a' to lines matching word under cursor
--   <leader>m/    Apply macro 'a' to lines matching last search pattern
--   Tip: \zs in :s/ sets match start, e.g. :%s/Expenses:\zsOld/New/g keeps "Expenses:"
--
-- CLAUDE CODE (coder/claudecode.nvim)
--   <leader>cc    Toggle Claude Code terminal
--   <leader>co    Open Claude Code
--   <leader>cx    Close Claude Code
--   <leader>cs    Send selection to Claude (visual mode)
--
-- GIT (Neogit + Diffview + Gitsigns)
--   <leader>gg    Neogit status (stage, commit, push)
--   <leader>gd    Diff working tree vs index
--   <leader>gD    Diff against main branch (PR review)
--   <leader>gh    Current file git history
--   <leader>gH    Branch history
--   <leader>gq    Close diffview
--   <leader>gb    Toggle inline blame
--   <leader>gt    Git status (Telescope, NvChad default)
--   <leader>cm    Git commits (Telescope, NvChad default)
--
-- MISC
--   ;             Enter command mode (custom)
--   jj            Exit insert mode (custom)
--   <leader>cp    Copy relative path (custom)
--   <leader>cP    Copy absolute path (custom)
--   <leader>cR    Reload options.lua (custom)
--   <leader>cT    Reload theme/highlights (custom)
--   <leader>ch    Cheatsheet (all keybindings)
--   <leader>ln    Toggle line numbers (custom, moved from <leader>n)
--   <leader>rn    Toggle relative numbers
--   <Esc>         Clear search highlight
--
-- ============================================================================

local map = vim.keymap.set

-- General
map("n", "<leader>X", "<cmd>tabclose<cr>", { desc = "Close current tab" })
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")
map("n", "<leader>ln", "<cmd>set nu!<cr>", { desc = "Toggle line numbers" })

-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal Exit insert mode" })

-- Copy file paths to clipboard
map("n", "<leader>cp", function() vim.fn.setreg("+", vim.fn.expand("%")) end, { desc = "Copy relative path" })
map("n", "<leader>cP", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, { desc = "Copy absolute path" })

-- Config reload
map("n", "<leader>cR", "<cmd>luafile ~/.config/nvim/lua/options.lua<cr>", { desc = "Reload options.lua" })
map("n", "<leader>cT", function() require("base46").load_all_highlights() end, { desc = "Reload theme" })

-- Buffers
map("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      local wins = vim.fn.win_findbuf(buf)
      if #wins == 0 then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end
end, { desc = "Buffer close hidden" })

-- Telescope
map("n", "<leader>fW", "<cmd>Telescope resume<cr>", { desc = "Resume last search" })

-- Harpoon
local harpoon = require("harpoon")
map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
map("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
map("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
map("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
map("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
map("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- LSP Codelens
map("n", "<leader>rt", vim.lsp.codelens.run, { desc = "Run test (codelens)" })

-- Macros - apply to matching lines
map("n", "<leader>ma", ":g/<C-r><C-w>/normal @a<CR>", { desc = "Macro run on word" })
map("n", "<leader>m/", ":g//normal @a<CR>", { desc = "Macro run on search" })

-- Git (Neogit + Diffview)
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Git status (neogit)" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git diff index" })
map("n", "<leader>gD", "<cmd>DiffviewOpen main<cr>", { desc = "Git diff main" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Git branch history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Git close diffview" })

-- Gitsigns
map("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Git toggle blame" })
