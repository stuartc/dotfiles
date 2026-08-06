require "nvchad.mappings"

-- Remove NvChad defaults that are too easy to hit accidentally
vim.keymap.del("n", "<leader>n")
vim.keymap.del("n", "<leader>pt")  -- Remapped to <leader>ft below
vim.keymap.del("n", "<C-n>")      -- Free for vim-visual-multi
vim.keymap.del("n", "<leader>e")   -- Re-bound below as nvim-tree toggle
-- NOTE: This removes the ability to create *new* horizontal terminals via keymap.
-- Use the command palette ("Terminal: New Horizontal") or <A-h> to toggle instead.
vim.keymap.del("n", "<leader>h")   -- Frees <leader>h* for gitsigns hunks

-- ============================================================================
-- Keybindings Reference (leader = Space)
-- ============================================================================
--
-- TELESCOPE (Fuzzy Finding)
--   <leader>ff    Find files (smart_open: frecency + fuzzy)
--   <leader>fF    Find files (plain, no ranking)
--   <leader>fw    Find word (live grep)
--   <leader>fW    Resume last search (custom)
--   <leader>fb    Find buffers
--   <leader>fo    Find oldfiles (recent)
--   <leader>fz    Find in current buffer
--   <leader>ft    Find terminals (custom, moved from <leader>pt)
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
--   <leader>e     Toggle file tree
--
-- MULTI-CURSOR (vim-visual-multi)
--   <C-n>         Select word / next match
--   <C-Up/Down>   Add cursor above/below
--   q             Skip current match
--   Q             Remove cursor
--   \\A           Select all matches
--
-- BUFFERS & TABS
--   <Tab>         Next buffer
--   <S-Tab>       Previous buffer
--   <leader>x     Close buffer
--   <leader>bo    Close hidden buffers (custom)
--   <leader>tn    New tab
--   <leader>tl    Next tab
--   <leader>th    Previous tab
--   <leader>tx    Close tab
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
--   <leader>1-4   Jump to harpoon file 1/2/3/4
--
-- WINDOW / PANE NAVIGATION (smart-splits.nvim)
--   <C-h/j/k/l>   Move between splits; crosses into tmux panes at the edge
--   <leader>rr    Resize submode (then hjkl to resize, <Esc>/q to leave)
--
-- SURROUND (nvim-surround)
--   ys{motion}{char}  Add surround (e.g. ysiw" surrounds word with ")
--   yss{char}         Surround entire line
--   ds{char}          Delete surround (e.g. ds" deletes surrounding ")
--   cs{old}{new}      Change surround (e.g. cs"' changes " to ')
--   dst               Delete surrounding HTML tag
--   cst<tag>          Change surrounding tag (e.g. cst<div>)
--   St<tag>           Surround selection with HTML tag (visual mode)
--   Sc                Surround selection with ``` codefence (visual-line mode)
--   Sb                Surround selection with **bold** (markdown only)
--   Ss                Surround selection with ~~strikethrough~~ (markdown only)
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
--   q             Close Diffview (when inside Diffview buffers)
--   ]c / [c       Next/previous hunk
--   <leader>hs    Stage hunk (visual: stage selection)
--   <leader>hr    Reset hunk (visual: reset selection)
--   <leader>hS    Stage entire buffer
--   <leader>hR    Reset entire buffer
--   <leader>hu    Undo stage hunk
--   <leader>hp    Preview hunk
--   ih            Hunk text object (dih=delete, yih=yank, vih=select, cih=change)
--
-- COMMAND PALETTE (snacks.nvim)
--   <leader>p     Open command palette (fuzzy search all commands)
--
-- OPEN EXTERNAL
--   <leader>oo    Open current file in default macOS app (custom)
--   <C-o>         (in Telescope) Open selected file in default macOS app
--
-- FOCUS MODE (no-neck-pain + twilight)
--   <leader>z     Toggle Focus Mode (center buffer)
--   :Twilight     Toggle Twilight independently
--   :RenderMarkdown toggle    Toggle markdown rendering
--
-- ITERM2 SPARE PANE
--   <leader>ts    Run command in spare pane (prompts)
--   <leader>tt    Run mix test on current file
--   <leader>tl    Run mix test on current line
--
-- MISC
--   ;             Enter command mode (custom)
--   jj            Exit insert mode (custom)
--   <A-j>         Blank line below, cursor stays (custom)
--   <A-k>         Blank line above, cursor stays (custom)
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

-- File tree
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })

-- Tabs
map("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "Tab new" })
map("n", "<leader>tl", "<cmd>tabnext<cr>", { desc = "Tab next" })
map("n", "<leader>th", "<cmd>tabprevious<cr>", { desc = "Tab previous" })
map("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "Tab close" })

-- General
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")
map("n", "<leader>ln", "<cmd>set nu!<cr>", { desc = "Toggle line numbers" })

-- Blank line above/below, cursor stays put
map("n", "<A-j>", "m`o<Esc>``", { desc = "Blank line below" })
map("n", "<A-k>", "m`O<Esc>``", { desc = "Blank line above" })

-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal Exit insert mode" })

-- Copy file paths to clipboard
map("n", "<leader>cp", function() vim.fn.setreg("+", vim.fn.expand("%")) end, { desc = "Copy relative path" })
map("n", "<leader>cP", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, { desc = "Copy absolute path" })

-- Config reload
map("n", "<leader>cR", "<cmd>luafile ~/.config/nvim/lua/options.lua<cr>", { desc = "Reload options.lua" })
map("n", "<leader>cT", function() require("base46").load_all_highlights() end, { desc = "Reload theme" })

-- Buffers (remap <leader>b from NvChad to <leader>bn so which-key waits for second key)
vim.keymap.del("n", "<leader>b")
map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "Buffer new" })
map("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  local skipped = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      local wins = vim.fn.win_findbuf(buf)
      if #wins == 0 then
        if vim.bo[buf].modified then
          skipped = skipped + 1
        else
          vim.api.nvim_buf_delete(buf, {})
        end
      end
    end
  end
  if skipped > 0 then
    vim.notify(skipped .. " modified buffer(s) left open", vim.log.levels.WARN)
  end
end, { desc = "Close other buffers" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope smart_open<cr>", { desc = "Find files (smart)" })
map("n", "<leader>fF", "<cmd>Telescope find_files<cr>", { desc = "Find files (plain)" })
map("n", "<leader>fW", "<cmd>Telescope resume<cr>", { desc = "Resume last search" })
map("n", "<leader>ft", "<cmd>Telescope terms<cr>", { desc = "Find terminals" })

-- Harpoon
local harpoon = require("harpoon")
map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
map("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
-- <C-hjkl> now drive smart-splits navigation (see plugins/smart-splits.lua);
-- harpoon file-jumps moved to <leader>1-4.
map("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
map("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
map("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
map("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

-- Window / pane navigation (smart-splits.nvim). Defined here, after
-- `require "nvchad.mappings"` above, so they override NvChad's default
-- <C-hjkl> = <C-w>hjkl window maps — those move between nvim splits but do NOT
-- hand off to tmux panes at the layout edge, which is the whole point.
map("n", "<C-h>", function() require("smart-splits").move_cursor_left() end, { desc = "Move to split/pane left" })
map("n", "<C-j>", function() require("smart-splits").move_cursor_down() end, { desc = "Move to split/pane down" })
map("n", "<C-k>", function() require("smart-splits").move_cursor_up() end, { desc = "Move to split/pane up" })
map("n", "<C-l>", function() require("smart-splits").move_cursor_right() end, { desc = "Move to split/pane right" })

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

-- Open in external app
map("n", "<leader>oo", "<cmd>OpenExternal<CR>", { desc = "Open in external app" })

