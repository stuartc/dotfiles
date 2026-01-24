require "nvchad.options"

-- Custom config
if vim.g.neovide then
  -- https://neovide.dev/configuration.html
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
  vim.g.neovide_cursor_animation_length = 0.090

  vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
  vim.keymap.set('v', '<D-c>', '"+y') -- Copy
  vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
  vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
  vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode
end


-- Custom snippets path (loaded by NvChad's luasnip config)
vim.g.vscode_snippets_path = vim.fn.stdpath("config") .. "/snippets"

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Show ruler at 80 columns
o.colorcolumn = "80"

-- Enable project-local config files (.nvim.lua in project directories)
o.exrc = true

-- Auto-reload files changed outside of Neovim
o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    -- Skip in command-line window where checktime is invalid
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Window title: show project name and git branch
vim.opt.title = true
vim.opt.titlestring = "%{v:lua.GetProjectTitle()}"

function _G.GetProjectTitle()
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
  if branch ~= "" then
    return cwd .. " (" .. branch .. ")"
  end
  return cwd
end

-- Register .bean files as beancount
vim.filetype.add({
  extension = {
    bean = "beancount",
  },
})

-- Disable folding for beancount files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "beancount",
  callback = function()
    vim.opt_local.foldenable = false
  end,
})

-- To see all available colors, run in Neovim:
--   :lua print(vim.inspect(require("base46").get_theme_tb("base_30")))
--
--   Common colors in base_30:
--   - white, black, darker_black, grey, light_grey
--   - red, green, yellow, orange, blue, purple, cyan, teal, pink
--   - baby_pink, nord_blue, sun, vibrant_green
--
--   There's also base_16 for base16 colors if you need them:
--   :lua print(vim.inspect(require("base46").get_theme_tb("base_16")))

-- Beancount syntax highlighting overrides (theme-aware)
vim.defer_fn(function()
  local colors = require("base46").get_theme_tb("base_30")
  
  vim.api.nvim_set_hl(0, "@variable.member.beancount", { fg = colors.blue })  -- Dates
  vim.api.nvim_set_hl(0, "@type.beancount", { fg = colors.teal })  -- Accounts
  vim.api.nvim_set_hl(0, "@label.beancount", { fg = colors.orange })            -- Metadata keys
  vim.api.nvim_set_hl(0, "@string.beancount", { fg = colors.white })             -- Strings

  vim.api.nvim_set_hl(0, "@spell.beancount", { bold = true })  -- just bold, no color
end, 0)

-- Project color signifier (iTerm2 tab + statusline)
-- Override with vim.g.project_color = "#hexcolor" in project .nvim.lua
vim.defer_fn(function()
  local ok, pc = pcall(require, "configs.project-colors")
  if ok then
    pc.apply()
  end
end, 100)

-- Re-apply on directory change
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    local ok, pc = pcall(require, "configs.project-colors")
    if ok then
      pc.apply()
    end
  end,
})

-- Reset iTerm tab on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local ok, pc = pcall(require, "configs.project-colors")
    if ok then
      pc.reset_iterm_tab()
    end
  end,
})

-- Open file in default macOS app
vim.api.nvim_create_user_command("OpenExternal", function(opts)
  local file = opts.args ~= "" and opts.args or vim.fn.expand("%:p")
  require("utils").open_external(file)
end, { nargs = "?", complete = "file" })
