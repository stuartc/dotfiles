require("nvchad.configs.lspconfig").defaults()

-- Default LSP settings for all servers
vim.lsp.config("*", {
  root_markers = { ".git" },
})

-- Python is split across two servers: basedpyright does types, hover and
-- navigation; ruff does lint diagnostics, code actions and formatting.
--
-- The nested root_markers list is a priority group — a project file wins over
-- the enclosing `.git` root, so a Python package inside a monorepo resolves to
-- its own directory rather than the repo top.
vim.lsp.config("basedpyright", {
  root_markers = { { "pyproject.toml", "setup.py", "setup.cfg" }, ".git" },
  settings = {
    basedpyright = {
      analysis = {
        -- basedpyright ships "recommended", which is far stricter than
        -- pyright's default and buries untyped code in diagnostics.
        typeCheckingMode = "standard",
        -- ruff sorts imports; two competing code actions is just confusing.
        disableOrganizeImports = true,
      },
    },
  },
  -- Without an explicit interpreter the server resolves imports against
  -- whatever `python3` is on PATH, so every third-party import in an
  -- unactivated project reads as unresolved.
  before_init = function(_, config)
    local python = config.root_dir and config.root_dir .. "/.venv/bin/python"
    if python and vim.uv.fs_stat(python) then
      config.settings.python = { pythonPath = python }
    end
  end,
})

vim.lsp.config("ruff", {
  root_markers = { { "pyproject.toml", "ruff.toml", ".ruff.toml" }, ".git" },
})

-- Let basedpyright own hover — ruff attaches a hover provider that mostly
-- answers "no documentation available" and wins by attach order. Done as an
-- autocmd rather than an on_attach so it stacks with NvChad's defaults()
-- instead of replacing them.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
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
