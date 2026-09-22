local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    elixir = { "mix" },
    heex = { "mix" },
    eelixir = { "mix" },
    python = { "ruff_organize_imports", "ruff_format" },
    rust = { "rustfmt" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- Python and Rust only — ruff and rustfmt are fast enough to be invisible on
  -- save, and formatting is settled enough in those ecosystems not to fight
  -- anyone. Every other filetype stays manual via the "LSP: Format file"
  -- palette entry; return nil to skip. Note this needs `event = "BufWritePre"`
  -- on the conform spec, otherwise the plugin is never loaded by the time a
  -- write happens.
  format_on_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft ~= "python" and ft ~= "rust" then
      return nil
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
}

return options
