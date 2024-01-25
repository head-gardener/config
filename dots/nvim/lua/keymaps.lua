-- Splits navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { noremap = true })

-- Custom functions
vim.keymap.set('n', 'gsg', ':call SynGroup()<CR>', { noremap = true })
vim.keymap.set('n', 'gsc', ':PSourceCurrent<CR>', { noremap = true })
vim.keymap.set('n', 'glu', ':PLookUp<CR>', { noremap = true })
vim.keymap.set('n', '<Space>si', ':PSwitch<CR>', { noremap = true })

-- Settings
vim.keymap.set('n', '<Leader>sl', ':set list!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>sb', ':set lbr!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>sw', ':set wrap!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>ss', ':set spell!<CR>', { noremap = true })

-- Terminal
local iron = require('iron.core')
vim.keymap.set('n', '<Space>ts', function() iron.repl_for('sh') end, { noremap = true })
vim.keymap.set('n', '<Space>tb', function()
  -- I should be banned from programming for this
  local cfg = require('iron.config')
  local f = cfg.repl_open_cmd
  cfg.repl_open_cmd = "botright 20 split",
  -- cfg should be read before using or cmd won't be set
  -- or something idk, doesn't work without the assert.
  assert(cfg.repl_open_cmd)
  iron.repl_for('sh')
  cfg.repl_open_cmd = f
end, { noremap = true })
vim.keymap.set('n', '<Space>tq', function() iron.close_repl('sh') end, { noremap = true })
vim.keymap.set('n', '<Space>t<Space>', function() iron.send('sh', '\3') end, { noremap = true })
vim.keymap.set('n', '<Space>tf', function()
  iron.focus_on('sh')
  vim.cmd('startinsert')
end, { noremap = true })
vim.keymap.set('n', '<Space>th', function() iron.hide_repl('sh') end, { noremap = true })
vim.keymap.set('n', '<Space>tk', function() iron.send('sh', '\27[A') end, { noremap = true })

-- Folds
vim.keymap.set({ 'n', 'v' }, '<M-h>', '[z', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<M-l>', ']z', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<M-j>', 'zj', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<M-k>', 'zk', { noremap = true })
vim.keymap.set('n', '<Space>a', 'zA', { noremap = true })
vim.keymap.set('n', '<Space>g', 'za', { noremap = true })

-- Shortcuts
vim.keymap.set('n', '<Space>p', ':b#<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>w', ':w<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>hh', ':noh<CR>', { noremap = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })
vim.keymap.set('n', '<Space>yp', '"0p<CR>', { noremap = true })
