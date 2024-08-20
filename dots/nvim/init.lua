vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = "\\"

-- require('lazy-bootstrap')
require('lazy').setup('plugins', {
})
require('functions')
require('config')
require('keymaps')

local function update_hl(group, tbl)
  local old_hl = vim.api.nvim_get_hl_by_name(group, true)
  local new_hl = vim.tbl_extend('force', old_hl, tbl)
  vim.api.nvim_set_hl(0, group, new_hl)
end

update_hl('Comment', { italic = true })
