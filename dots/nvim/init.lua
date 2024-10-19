vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = ";"
vim.g.maplocalleader = " "
vim.keymap.set({ 'n', 'v' }, ';;', ';', { noremap = true })

-- require('lazy-bootstrap')
require('lazy').setup('plugins', {
  dev = {
    path = "~/Code",
    patterns = {},
    fallback = true,
  }
})
require('functions')
require('config')
require('keymaps')

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()

    local motd = require('lib.motd')
    require('notify').notify(motd.get_mapoftheday(), vim.log.levels.INFO, {
      title = "Map Of The Day!",
    })

  end
})
