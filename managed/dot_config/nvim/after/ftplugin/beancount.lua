vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2

-- ]] / [[ jump to the next/previous transaction's date line. A transaction
-- starts with `YYYY-MM-DD <flag>` where flag is `*` (cleared) or `!` (open).
-- Counts work (3]]) and the previous position is added to the jumplist.
local function jump(forward)
  for _ = 1, vim.v.count1 do
    vim.fn.search([=[\v^\d{4}-\d{2}-\d{2}\s+[*!]]=], forward and "Ws" or "bWs")
  end
end

vim.keymap.set("n", "]]", function() jump(true) end, { buffer = true, desc = "Next transaction" })
vim.keymap.set("n", "[[", function() jump(false) end, { buffer = true, desc = "Previous transaction" })
