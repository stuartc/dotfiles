local M = {}

-- Open a file in the default macOS app
function M.open_external(file)
  if not file or file == "" then
    vim.notify("No file to open", vim.log.levels.WARN)
    return
  end
  vim.fn.system({ "open", file })
end

return M
