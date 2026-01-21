-- Project color signifier for visual project identification
-- Colors iTerm2 tab and Neovim statusline based on project
-- Override with vim.g.project_color in .nvim.lua

local M = {}

-- Convert hex color string to RGB table
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16),
  }
end

-- Better hash function using FNV-1a with additional mixing
local function hash_string(str)
  -- FNV-1a hash
  local hash = 2166136261
  for i = 1, #str do
    hash = bit.bxor(hash, str:byte(i))
    hash = (hash * 16777619) % 4294967296
  end
  -- Additional mixing for better distribution
  hash = bit.bxor(hash, bit.rshift(hash, 16))
  hash = (hash * 2246822507) % 4294967296
  hash = bit.bxor(hash, bit.rshift(hash, 13))
  return hash
end

-- Generate consistent hex color from string (project name)
-- Uses HSL with fixed saturation/lightness for good visibility
function M.hash_to_color(str)
  -- Use just the project name (last directory component) for hashing
  -- This gives better differentiation between projects
  local project_name = str:match("([^/]+)$") or str
  local hash = hash_string(project_name)
  -- Use golden ratio to spread hues more evenly
  local hue = (hash * 0.618033988749895) % 1 * 360
  local saturation = 0.25  -- 25% saturation for muted colors matching theme
  local lightness = 0.35   -- 35% lightness for softer appearance

  -- HSL to RGB conversion
  local c = (1 - math.abs(2 * lightness - 1)) * saturation
  local x = c * (1 - math.abs((hue / 60) % 2 - 1))
  local m = lightness - c / 2

  local r, g, b
  if hue < 60 then
    r, g, b = c, x, 0
  elseif hue < 120 then
    r, g, b = x, c, 0
  elseif hue < 180 then
    r, g, b = 0, c, x
  elseif hue < 240 then
    r, g, b = 0, x, c
  elseif hue < 300 then
    r, g, b = x, 0, c
  else
    r, g, b = c, 0, x
  end

  r = math.floor((r + m) * 255)
  g = math.floor((g + m) * 255)
  b = math.floor((b + m) * 255)

  return string.format("#%02x%02x%02x", r, g, b)
end

-- Calculate contrasting foreground color (white or black)
function M.get_contrast_color(hex_color)
  local rgb = hex_to_rgb(hex_color)
  -- Calculate relative luminance using sRGB formula
  local luminance = (0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b) / 255
  -- Return white for dark backgrounds, black for light backgrounds
  return luminance > 0.5 and "#000000" or "#ffffff"
end

-- Get project color (manual override or auto-generated)
function M.get_color()
  if vim.g.project_color then
    return vim.g.project_color
  end
  return M.hash_to_color(vim.fn.getcwd())
end

-- Apply color to iTerm2 tab using escape sequences
function set_iterm_tab(hex_color)
  local rgb = hex_to_rgb(hex_color)
  -- OSC 6;1;bg;red/green/blue;brightness;N sequences for iTerm2
  local esc = string.char(27)
  local bel = string.char(7)
  io.write(esc .. "]6;1;bg;red;brightness;" .. rgb.r .. bel)
  io.write(esc .. "]6;1;bg;green;brightness;" .. rgb.g .. bel)
  io.write(esc .. "]6;1;bg;blue;brightness;" .. rgb.b .. bel)
end

-- Reset iTerm2 tab to default
function M.reset_iterm_tab()
  local esc = string.char(27)
  local bel = string.char(7)
  io.write(esc .. "]6;1;bg;*;default" .. bel)
end

-- Color the statusline folder icon (CWD section)
local function set_folder_icon(hex_color)
  local fg = M.get_contrast_color(hex_color)

  -- Get the statusline background for proper separator rendering
  local stl_bg
  local ok, colors = pcall(function()
    return require("base46").get_theme_tb("base_30")
  end)
  if ok and colors then
    stl_bg = colors.statusline_bg
  else
    -- Fallback: get from current StatusLine highlight
    local stl_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
    stl_bg = stl_hl.bg and string.format("#%06x", stl_hl.bg) or "NONE"
  end

  -- St_cwd_sep: powerline separator (fg draws the angle)
  -- St_cwd_icon: folder icon background
  vim.api.nvim_set_hl(0, "St_cwd_sep", { fg = hex_color, bg = stl_bg })
  vim.api.nvim_set_hl(0, "St_cwd_icon", { fg = fg, bg = hex_color })
end

-- Main function: apply project color everywhere
function M.apply()
  local color = M.get_color()
  set_iterm_tab(color)
  -- set_folder_icon(color)
end

return M
