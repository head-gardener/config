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
vim.keymap.set('n', 'gka', ':! kubectl apply -f %<CR>', {
  noremap = true,
  desc = 'Apply current file to k8s'
})

-- Settings
vim.keymap.set('n', '<Leader>sl', ':set list!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>sb', ':set lbr!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>sw', ':set wrap!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>ss', ':set spell!<CR>', { noremap = true })

-- Folds
vim.keymap.set({ 'n', 'v' }, '<M-h>', '[z', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<M-l>', ']z', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<M-j>', 'zj', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<M-k>', 'zk', { noremap = true })
vim.keymap.set('n', '<Space>a', 'zA', { noremap = true })
vim.keymap.set('n', '<Space>g', 'za', { noremap = true })
-- lens
vim.keymap.set('n', 'zl', 'zMzv', { noremap = true })

-- Shortcuts
vim.keymap.set('n', '<C-i>', '<C-a>', { noremap = true })
vim.keymap.set('n', '<Space>p', ':b#<CR>', { noremap = true })
vim.keymap.set('n', 'gQ', ':cope<CR>', { noremap = true })
vim.keymap.set('n', 'gq', ':cclose<CR>', { noremap = true })
vim.keymap.set('n', ']q', ':cnext<CR>', { noremap = true })
vim.keymap.set('n', '[q', ':cprev<CR>', { noremap = true })
vim.keymap.set('n', '<BS>', ':bprev<CR>', { noremap = true })
vim.keymap.set('n', '<M-BS>', ':bnext<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>w', ':w<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>W', ':wa<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>hh', ':noh<CR>', { noremap = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })
vim.keymap.set('n', '<Space>yp', '"0p<CR>', { noremap = true })
vim.keymap.set('i', '<M-j>', '<Esc>', { noremap = true })
