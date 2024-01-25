-- swap make with mix as the build tool
vim.keymap.set('n', '<Leader>mm', ':!mix<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>mt', ':!mix test<CR>', { noremap = true })

-- launch the interpreter
vim.keymap.set('n', '<Leader>ri', ':term iex -S mix<CR>', { noremap = true })
