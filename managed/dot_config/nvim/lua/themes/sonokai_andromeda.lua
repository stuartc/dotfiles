-- Sonokai Andromeda theme for NvChad base46
-- Based on https://github.com/sainnhe/sonokai (andromeda variant)
--
-- Cache: NvChad compiles themes to ~/.local/share/nvim/base46/
-- If colors don't update after changes, regenerate the cache:
--   1. Delete cache:  rm -rf ~/.local/share/nvim/base46/
--   2. Rebuild:       nvim --headless -c 'lua require("base46").load_all_highlights()' -c 'qa'
--   3. Restart Neovim

local M = {}

-- UI Colors (30 colors)
M.base_30 = {
  white = "#e1e3e4",
  darker_black = "#181a1c",
  black = "#2b2d3a",  -- main background
  black2 = "#333648",
  one_bg = "#3f445b",
  one_bg2 = "#454a62",
  one_bg3 = "#4b5069",
  grey = "#5a5e7a",
  grey_fg = "#656a85",
  grey_fg2 = "#70758f",
  light_grey = "#7e8294",
  red = "#fb617e",
  baby_pink = "#ff8da3",
  pink = "#f37895",
  line = "#333648",
  green = "#9ed06c",
  vibrant_green = "#a8da78",
  nord_blue = "#6dcae8",
  blue = "#6dcae8",
  yellow = "#edc763",
  sun = "#f5d980",
  purple = "#bb97ee",
  dark_purple = "#9a7cd1",
  teal = "#6dcae8",
  orange = "#f89860",
  cyan = "#6dcae8",
  statusline_bg = "#21232b",
  lightbg = "#363a4e",
  pmenu_bg = "#9ed06c",
  folder_bg = "#6dcae8",
}

-- Syntax highlighting colors (base16)
M.base_16 = {
  base00 = "#2b2d3a",  -- Default background
  base01 = "#333648",  -- Lighter background (status bars, line numbers)
  base02 = "#3f445b",  -- Selection background
  base03 = "#7e8294",  -- Comments, invisibles
  base04 = "#5a5e7a",  -- Dark foreground
  base05 = "#e1e3e4",  -- Default foreground
  base06 = "#e1e3e4",  -- Light foreground
  base07 = "#ffffff",  -- Lightest foreground
  base08 = "#fb617e",  -- Variables, XML tags, markup link text
  base09 = "#f89860",  -- Integers, booleans, constants
  base0A = "#edc763",  -- Classes, markup bold, search text background
  base0B = "#9ed06c",  -- Strings, inherited class, markup code
  base0C = "#6dcae8",  -- Support, regular expressions
  base0D = "#6dcae8",  -- Functions, methods, attributes
  base0E = "#bb97ee",  -- Keywords, storage
  base0F = "#fb617e",  -- Deprecated, opening/closing embedded language tags
}

M.type = "dark"

-- Custom highlight overrides using theme colors
-- statusline_bg (#21232b) matches VSCode file explorer background
-- polish_hl must be nested by integration name (nvimtree, telescope, etc.)
M.polish_hl = {
  nvimtree = {
    NvimTreeNormal = { bg = M.base_30.statusline_bg },
    NvimTreeNormalNC = { bg = M.base_30.statusline_bg },
  },
  telescope = {
    -- Borderless style: borders match backgrounds to hide them
    TelescopeNormal = { bg = M.base_30.statusline_bg },
    TelescopePreviewNormal = { bg = M.base_30.statusline_bg },
    TelescopePromptNormal = { bg = M.base_30.black },
    TelescopeResultsNormal = { bg = M.base_30.statusline_bg },
    TelescopeBorder = { fg = M.base_30.statusline_bg, bg = M.base_30.statusline_bg },
    TelescopePromptBorder = { fg = M.base_30.black, bg = M.base_30.black },
    TelescopePreviewBorder = { fg = M.base_30.statusline_bg, bg = M.base_30.statusline_bg },
    TelescopeResultsBorder = { fg = M.base_30.statusline_bg, bg = M.base_30.statusline_bg },
    TelescopeResultsTitle = { fg = M.base_30.statusline_bg, bg = M.base_30.statusline_bg },
  },
}

M = require("base46").override_theme(M, "sonokai_andromeda")

return M
