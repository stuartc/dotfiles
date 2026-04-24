vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2

-- Transform a single line per Obsidian-style todo rules.
-- Precedence: toggle existing checkbox > add checkbox to list item > convert plain line.
local function transform_line(line)
  if line:match("%[x%]") then
    return (line:gsub("%[x%]", "[ ]", 1))
  end
  if line:match("%[ %]") then
    return (line:gsub("%[ %]", "[x]", 1))
  end
  local indent, marker, rest = line:match("^(%s*)([%-%*%+])%s+(.*)$")
  if marker then
    return indent .. marker .. " [ ] " .. rest
  end
  local oindent, num, orest = line:match("^(%s*)(%d+%.)%s+(.*)$")
  if num then
    return oindent .. num .. " [ ] " .. orest
  end
  local pindent, prest = line:match("^(%s*)(.*)$")
  return pindent .. "- [ ] " .. prest
end

-- Toggle/convert the current line; keep cursor on the same logical text.
local function toggle_current()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local new = transform_line(line)
  vim.api.nvim_set_current_line(new)
  local delta = #new - #line
  vim.api.nvim_win_set_cursor(0, { row, math.max(0, col + delta) })
end

-- Apply transform_line to every line in the inclusive row range.
local function toggle_range(start_row, end_row)
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  for i, line in ipairs(lines) do
    lines[i] = transform_line(line)
  end
  vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, lines)
end

-- Toggle/convert every line in the current visual selection, then leave visual.
local function toggle_visual()
  local s = vim.fn.line("v")
  local e = vim.fn.line(".")
  if s > e then
    s, e = e, s
  end
  toggle_range(s, e)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

for _, lhs in ipairs({ "<leader>tt", "<M-l>" }) do
  vim.keymap.set("n", lhs, toggle_current, { buffer = true, desc = "Toggle/convert markdown todo" })
  vim.keymap.set("x", lhs, toggle_visual, { buffer = true, desc = "Toggle/convert markdown todos in selection" })
end
vim.keymap.set("i", "<M-l>", toggle_current, { buffer = true, desc = "Toggle/convert markdown todo" })
