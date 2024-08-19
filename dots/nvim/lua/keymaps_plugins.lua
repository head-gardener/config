-- Iron
vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')

-- Symbols outline
vim.keymap.set('n', '<Leader>sd', ':SymbolsOutline<CR>', { noremap = true })

-- Commentary
vim.keymap.set({ 'n', 'v' }, '<C-/>', ':Commentary<CR>', { noremap = true })
-- alt keymap for tmux - it sends C-/ as C-_
vim.keymap.set({ 'n', 'v' }, '<C-_>', ':Commentary<CR>', { noremap = true })

-- Zen
vim.keymap.set('n', '<Space>ze', ':ZenMode<CR>', { noremap = true })

-- Twilight
vim.keymap.set('n', '<Space>tw', ':Twilight<CR>', { noremap = true })

-- Cosco
vim.keymap.set("n", "<Space>;", function()
  require("cosco").comma_or_semi_colon()
end, {
    noremap = true,
    silent = true,
    desc = "Auto comma or semicolon"
})

-- Telescope
local tbuiltin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>fo', ":Telescope hoogle list<CR>", { noremap = true, desc = 'Telescope hoogle search'})
vim.keymap.set('n', '<Leader>fc', ":Telescope builtin<CR>", { noremap = true, desc = 'Telescope commands'})
vim.keymap.set('n', '<Leader>ff', tbuiltin.find_files, { noremap = true, desc = "Telescope find file" })
vim.keymap.set('n', '<Leader>fg', tbuiltin.live_grep, { noremap = true, desc = "Telescope live grep" })
vim.keymap.set('n', '<Leader>fd', ":Telescope diagnostics<CR>", { noremap = true, desc = "Telescope diagnostics" })
vim.keymap.set('n', '<Leader>fb', ":Telescope file_browser<CR>", { noremap = true, desc = "Telescope file browser" })
vim.keymap.set('n', '<Leader>fh', tbuiltin.help_tags, { noremap = true, desc = "Telescope help tags" })
vim.keymap.set('n', '<Leader>ft', tbuiltin.treesitter, { noremap = true, desc = "Telescope treesitter search" })

-- Gitsigns
vim.keymap.set('n', '<Space>hs', ':Gitsigns stage_hunk<CR>', { noremap = true })
vim.keymap.set('n', '<Space>nh', ':Gitsigns next_hunk<CR>', { noremap = true })
vim.keymap.set('n', '<Space>hr', ':Gitsigns reset_hunk<CR>', { noremap = true })

require 'nvim-treesitter.configs'.setup {
  ensure_installed = {},
  sync_install = false,
  ignore_install = {},
  highlight = {
    enable = true,
    disable = {},
  },
}

-- CMP thing
local cmp = require('cmp')
local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      else
        fallback()
      end
    end, { "i", "s", noremap = true }),
    ['<S-Tab>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" })
  },
})
