local M = {}

-- Commands for the palette
-- action can be:
--   ":command"  - vim command (starts with :)
--   "keys"      - keymap sequence (fed as keys)
--   function    - lua function to execute
-- icon: Nerd Font icon
-- hl: highlight group for the icon
-- desc: short description shown in grey
M.commands = {
  -- Git  
  { name = "Git: Status (Neogit)", action = ":Neogit", icon = "", hl = "diffAdded", desc = "Stage, commit, push" },
  { name = "Git: Diff working tree", action = ":DiffviewOpen", icon = "", hl = "diffAdded", desc = "Changes vs HEAD" },
  { name = "Git: Diff against main", action = ":DiffviewOpen main", icon = "", hl = "diffAdded", desc = "Changes vs main branch" },
  { name = "Git: File history", action = ":DiffviewFileHistory %", icon = "", hl = "diffAdded", desc = "Commits for current file" },
  { name = "Git: Branch history", action = ":DiffviewFileHistory", icon = "", hl = "diffAdded", desc = "All commits on branch" },
  { name = "Git: Close diffview", action = ":DiffviewClose", icon = "", hl = "diffAdded", desc = "Close diff panels" },
  { name = "Git: Toggle inline blame", action = ":Gitsigns toggle_current_line_blame", icon = "", hl = "diffAdded", desc = "Show/hide line blame" },

  -- Telescope
  { name = "Find: Files", action = ":Telescope find_files", icon = "", hl = "Directory", desc = "Search by filename" },
  { name = "Find: Grep (live)", action = ":Telescope live_grep", icon = "", hl = "Directory", desc = "Search file contents" },
  { name = "Find: Resume last search", action = ":Telescope resume", icon = "", hl = "Directory", desc = "Continue previous search" },
  { name = "Find: Buffers", action = ":Telescope buffers", icon = "", hl = "Directory", desc = "Open buffers" },
  { name = "Find: Recent files", action = ":Telescope oldfiles", icon = "", hl = "Directory", desc = "Recently opened files" },
  { name = "Find: In current buffer", action = ":Telescope current_buffer_fuzzy_find", icon = "", hl = "Directory", desc = "Search this file" },
  { name = "Find: Commands", action = ":Telescope commands", icon = "", hl = "Directory", desc = "All vim commands" },
  { name = "Find: Keymaps", action = ":Telescope keymaps", icon = "", hl = "Directory", desc = "Keyboard shortcuts" },
  { name = "Find: Help tags", action = ":Telescope help_tags", icon = "", hl = "Directory", desc = "Vim documentation" },

  -- Buffers
  { name = "Buffer: Close current", action = ":bd", icon = "󰈔", hl = "Function", desc = "Close this buffer" },
  { name = "Buffer: Close hidden", action = "<leader>bo", icon = "󰈔", hl = "Function", desc = "Close non-visible buffers" },
  { name = "Buffer: Next", action = ":bnext", icon = "󰈔", hl = "Function", desc = "Go to next buffer" },
  { name = "Buffer: Previous", action = ":bprev", icon = "󰈔", hl = "Function", desc = "Go to previous buffer" },

  -- Tabs
  { name = "Tab: New", action = ":tabnew", icon = "󰓩", hl = "Function", desc = "Open new tab" },
  { name = "Tab: Close", action = ":tabclose", icon = "󰓩", hl = "Function", desc = "Close current tab" },
  { name = "Tab: Next", action = ":tabnext", icon = "󰓩", hl = "Function", desc = "Go to next tab" },
  { name = "Tab: Previous", action = ":tabprev", icon = "󰓩", hl = "Function", desc = "Go to previous tab" },

  -- LSP
  { name = "LSP: Format file", action = ":lua vim.lsp.buf.format()", icon = "󰅩", hl = "Keyword", desc = "Auto-format code" },
  { name = "LSP: Rename symbol", action = ":lua vim.lsp.buf.rename()", icon = "󰅩", hl = "Keyword", desc = "Rename across files" },
  { name = "LSP: Code action", action = ":lua vim.lsp.buf.code_action()", icon = "󰅩", hl = "Keyword", desc = "Quick fixes and refactors" },
  { name = "LSP: Go to definition", action = ":lua vim.lsp.buf.definition()", icon = "󰅩", hl = "Keyword", desc = "Jump to definition" },
  { name = "LSP: Find references", action = ":lua vim.lsp.buf.references()", icon = "󰅩", hl = "Keyword", desc = "Find all usages" },
  { name = "LSP: Hover info", action = ":lua vim.lsp.buf.hover()", icon = "󰅩", hl = "Keyword", desc = "Show docs at cursor" },
  { name = "LSP: Run codelens", action = ":lua vim.lsp.codelens.run()", icon = "󰅩", hl = "Keyword", desc = "Execute inline action" },
  { name = "LSP: Restart", action = ":LspRestart", icon = "󰅩", hl = "Keyword", desc = "Restart language server" },

  -- Harpoon
  { name = "Harpoon: Add file", action = "<leader>a", icon = "󰛢", hl = "String", desc = "Mark file for quick access" },
  { name = "Harpoon: Toggle menu", action = "<C-e>", icon = "󰛢", hl = "String", desc = "Show marked files" },

  -- Theme
  { name = "Theme: Pick theme", action = ":Telescope themes", icon = "", hl = "Constant", desc = "Browse colorschemes" },
  { name = "Theme: Reload highlights", action = ":lua require('base46').load_all_highlights()", icon = "", hl = "Constant", desc = "Refresh theme colors" },

  -- Config
  { name = "Config: Edit init.lua", action = ":e ~/.config/nvim/init.lua", icon = "", hl = "Special", desc = "Main nvim config" },
  { name = "Config: Edit plugins", action = ":e ~/.config/nvim/lua/plugins/init.lua", icon = "", hl = "Special", desc = "Plugin definitions" },
  { name = "Config: Edit mappings", action = ":e ~/.config/nvim/lua/mappings.lua", icon = "", hl = "Special", desc = "Keyboard shortcuts" },
  { name = "Config: Edit options", action = ":e ~/.config/nvim/lua/options.lua", icon = "", hl = "Special", desc = "Vim options" },
  { name = "Config: Reload options", action = ":luafile ~/.config/nvim/lua/options.lua", icon = "", hl = "Special", desc = "Apply options changes" },
  { name = "Config: Lazy sync", action = ":Lazy sync", icon = "", hl = "Special", desc = "Install and update plugins" },
  { name = "Config: Lazy update", action = ":Lazy update", icon = "", hl = "Special", desc = "Update plugins only" },
  { name = "Config: Mason", action = ":Mason", icon = "", hl = "Special", desc = "Manage LSP servers" },

  -- Terminal
  { name = "Terminal: Horizontal", action = "<A-h>", icon = "", hl = "Character", desc = "Split below" },
  { name = "Terminal: Vertical", action = "<A-v>", icon = "", hl = "Character", desc = "Split right" },
  { name = "Terminal: Float", action = "<A-i>", icon = "", hl = "Character", desc = "Floating window" },

  -- File
  { name = "File: Save", action = ":w", icon = "󰈙", hl = "Directory", desc = "Save current file" },
  { name = "File: Save all", action = ":wa", icon = "󰈙", hl = "Directory", desc = "Save all buffers" },
  { name = "File: Copy relative path", action = function() vim.fn.setreg("+", vim.fn.expand("%")) end, icon = "󰈙", hl = "Directory", desc = "Copy path to clipboard" },
  { name = "File: Copy absolute path", action = function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, icon = "󰈙", hl = "Directory", desc = "Copy full path to clipboard" },
  { name = "File: Toggle tree", action = ":NvimTreeToggle", icon = "󰈙", hl = "Directory", desc = "Show/hide file explorer" },
  { name = "File: Reveal in tree", action = ":NvimTreeFindFile", icon = "󰈙", hl = "Directory", desc = "Highlight in explorer" },

  -- View
  { name = "View: Toggle line numbers", action = ":set nu!", icon = "", hl = "Type", desc = "Show/hide line numbers" },
  { name = "View: Toggle relative numbers", action = ":set rnu!", icon = "", hl = "Type", desc = "Absolute vs relative" },
  { name = "View: Toggle wrap", action = ":set wrap!", icon = "", hl = "Type", desc = "Wrap long lines" },
  { name = "View: Cheatsheet", action = ":NvCheatsheet", icon = "", hl = "Type", desc = "Show keybindings" },

  -- Quickfix
  { name = "Quickfix: Open", action = ":copen", icon = "", hl = "DiagnosticInfo", desc = "Open quickfix list" },
  { name = "Quickfix: Close", action = ":cclose", icon = "", hl = "DiagnosticInfo", desc = "Close quickfix list" },
  { name = "Quickfix: Next", action = ":cnext", icon = "", hl = "DiagnosticInfo", desc = "Go to next item" },
  { name = "Quickfix: Previous", action = ":cprev", icon = "", hl = "DiagnosticInfo", desc = "Go to previous item" },

  -- Misc
  { name = "Quit: Save and quit", action = ":wq", icon = "󰗼", hl = "DiagnosticError", desc = "Save and exit nvim" },
  { name = "Quit: Force quit", action = ":q!", icon = "󰗼", hl = "DiagnosticError", desc = "Exit without saving" },
  { name = "Quit: Quit all", action = ":qa", icon = "󰗼", hl = "DiagnosticError", desc = "Close all and exit" },
}

function M.show()
  local items = {}
  for _, cmd in ipairs(M.commands) do
    local item = {
      text = cmd.name,
      action = cmd.action,
      desc = cmd.desc or "",
    }
    if cmd.icon then
      item.icon = cmd.icon
      item.hl = cmd.hl
    end
    table.insert(items, item)
  end

  Snacks.picker({
    title = "Command Palette",
    layout = {
      preset = "vscode",    -- or any preset
      preview = false,      -- you already have this
      -- Override preset dimensions:
      layout = {
        width = 0.4,        -- 40% of screen
        height = 0.6,
        max_width = 80,     -- cap in columns
        min_width = 40,
      }
    },
    items = items,
    format = function(item, _)
      local icon_text = item.icon and (item.icon .. " ") or "  "
      local icon_hl = item.icon and (item.hl or "Function") or nil
      return {
        { icon_text, icon_hl },
        { item.text },
        { "  " .. item.desc, "Comment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        local action = item.action
        if type(action) == "function" then
          action()
        elseif type(action) == "string" then
          if action:sub(1, 1) == ":" then
            vim.cmd(action:sub(2))
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(action, true, false, true), "m", false)
          end
        end
      end
    end,
  })
end

return M
