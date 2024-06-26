-- Syntax Tree Surfer
local opts = { noremap = true, silent = true }

-- Normal Mode Swapping:
-- Swap The Master Node relative to the cursor with it's siblings, Dot Repeatable
vim.keymap.set("n", "vU", function()
  vim.opt.opfunc = "v:lua.STSSwapUpNormal_Dot"
  return "g@l"
end, { silent = true, expr = true })
vim.keymap.set("n", "vD", function()
  vim.opt.opfunc = "v:lua.STSSwapDownNormal_Dot"
  return "g@l"
end, { silent = true, expr = true })

-- Swap Current Node at the Cursor with it's siblings, Dot Repeatable
vim.keymap.set("n", "vd", function()
  vim.opt.opfunc = "v:lua.STSSwapCurrentNodeNextNormal_Dot"
  return "g@l"
end, { silent = true, expr = true })
vim.keymap.set("n", "vu", function()
  vim.opt.opfunc = "v:lua.STSSwapCurrentNodePrevNormal_Dot"
  return "g@l"
end, { silent = true, expr = true })

-- Visual Selection from Normal Mode
vim.keymap.set("n", "vx", '<cmd>STSSelectMasterNode<cr>', opts)
vim.keymap.set("n", "vn", '<cmd>STSSelectCurrentNode<cr>', opts)

-- Select Nodes in Visual Mode
vim.keymap.set("x", "J", '<cmd>STSSelectNextSiblingNode<cr>', opts)
vim.keymap.set("x", "K", '<cmd>STSSelectPrevSiblingNode<cr>', opts)
vim.keymap.set("x", "H", '<cmd>STSSelectParentNode<cr>', opts)
vim.keymap.set("x", "L", '<cmd>STSSelectChildNode<cr>', opts)

-- Swapping Nodes in Visual Mode
vim.keymap.set("x", "<A-j>", '<cmd>STSSwapNextVisual<cr>', opts)
vim.keymap.set("x", "<A-k>", '<cmd>STSSwapPrevVisual<cr>', opts)

-- Iron
vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')

-- Picker
vim.keymap.set('n', '<Leader>pe', ':PickerEdit<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>ps', ':PickerVsplit<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>ph', ':PickerSplit<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>pb', ':PickerBuffer<CR>', { noremap = true })

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
