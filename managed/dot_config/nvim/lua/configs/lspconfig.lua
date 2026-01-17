require("nvchad.configs.lspconfig").defaults()

-- Default LSP settings for all servers
vim.lsp.config("*", {
  root_markers = { ".git" },
})

-- Servers to enable (install via Mason with :MasonInstall <name>)
-- TypeScript/JS: :MasonInstall typescript-language-server
local servers = { "html", "cssls", "ts_ls" }
vim.lsp.enable(servers)

-- Per-server custom config example:
-- vim.lsp.config("lua_ls", {
--   settings = {
--     Lua = {
--       diagnostics = { globals = { "vim" } },
--     },
--   },
-- })
