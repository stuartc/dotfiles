-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "sonokai_andromeda",
}

M.term = {
	sizes = {
		vsp = 0.3,
	},
}

-- Can possibly pass in a table instead of a key for setting our own separators
-- M.separators = {
--   default = { left = "", right = "" },
--   round = { left = "", right = "" },
--   block = { left = "█", right = "█" },
--   arrow = { left = "", right = "" },
-- }

M.ui = {
  statusline = {
    theme = "default",
    separator_style = "block",
    modules = {
      file = function()
        local stl_utils = require("nvchad.stl.utils")
        local config = require("nvconfig").ui.statusline
        local sep_style = config.separator_style
        local separators = (type(sep_style) == "table" and sep_style) or stl_utils.separators[sep_style]
        local sep_r = separators["right"]

        local icon = "󰈚"
        local stbufnr = stl_utils.stbufnr()
        local path = vim.api.nvim_buf_get_name(stbufnr)
        local name = "Empty"

        if path ~= "" then
          -- Get path relative to cwd
          local relative = vim.fn.fnamemodify(path, ":~:.")

          -- For deeply nested files, show last 3 components
          local parts = vim.split(relative, "/")
          if #parts > 3 then
            relative = "…/" .. table.concat(vim.list_slice(parts, #parts - 2), "/")
          end

          name = relative

          -- Get devicon if available
          local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
          if devicons_ok then
            local ft_icon = devicons.get_icon(path)
            icon = ft_icon or icon
          end
        end

        -- Add modified indicator
        local modified = vim.bo[stbufnr].modified and " " or ""

        -- Match default format exactly
        local display = " " .. name .. modified .. (sep_style == "default" and " " or "")
        return "%#St_file# " .. icon .. display .. "%#St_file_sep#" .. sep_r
      end,
    },
  },
}

-- M.nvdash = { load_on_startup = true }

return M
