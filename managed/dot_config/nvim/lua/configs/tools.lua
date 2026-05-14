-- Single source of truth for tools managed via Mason.
--
-- `lsp` lists LSP servers by their *lspconfig* name (e.g. `ts_ls`, not
-- `typescript-language-server`). mason-lspconfig translates these to the
-- correct Mason package names when installing, and `vim.lsp.enable` in
-- configs/lspconfig.lua reads the same list to enable them.
--
-- `extras` lists everything else Mason should install (formatters, linters,
-- DAP adapters) using their *Mason package* names — these go to
-- mason-tool-installer directly.
--
-- `parsers` lists nvim-treesitter parsers (main branch API). The plugin spec
-- and the headless bootstrap both read from here.
--
-- To add an LSP: append the lspconfig server name to `lsp` and restart nvim.
-- To add a formatter/linter: append the Mason package name to `extras`.
-- To add a TS parser: append the parser name to `parsers`.
return {
  lsp = { "html", "cssls", "ts_ls", "expert", "beancount" },
  extras = { "stylua", "prettierd" },
  parsers = {
    "vim", "lua", "vimdoc",
    "html", "css", "beancount",
    "typescript", "elixir", "heex",
    "markdown", "markdown_inline",
  },
}
