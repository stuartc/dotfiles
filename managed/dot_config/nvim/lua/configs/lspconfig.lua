require("nvchad.configs.lspconfig").defaults()

-- Default LSP settings for all servers
vim.lsp.config("*", {
  root_markers = { ".git" },
})

-- Enable servers listed in configs/tools.lua. Installation is handled by
-- mason-lspconfig (see lua/plugins/init.lua), which translates these
-- lspconfig names to Mason package names.
vim.lsp.enable(require("configs.tools").lsp)

-- Per-server custom config example:
-- vim.lsp.config("lua_ls", {
--   settings = {
--     Lua = {
--       diagnostics = { globals = { "vim" } },
--     },
--   },
-- })
