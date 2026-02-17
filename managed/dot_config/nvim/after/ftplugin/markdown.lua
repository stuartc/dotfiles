vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2

-- Toggle checkbox on current line: [ ] <-> [x]
vim.keymap.set("n", "<leader>tx", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("%[x%]") then
    vim.api.nvim_set_current_line((line:gsub("%[x%]", "[ ]", 1)))
  elseif line:match("%[ %]") then
    vim.api.nvim_set_current_line((line:gsub("%[ %]", "[x]", 1)))
  end
end, { buffer = true, desc = "Toggle todo checkbox" })

-- Insert a new todo item below and enter insert mode
vim.keymap.set("n", "<leader>tn", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { "- [ ] " })
  vim.api.nvim_win_set_cursor(0, { row + 1, 6 })
  vim.cmd("startinsert!")
end, { buffer = true, desc = "New todo item" })
