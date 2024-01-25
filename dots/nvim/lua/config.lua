-- Colorscheme
vim.cmd('set termguicolors')
-- vim.cmd('colorscheme gruvbox')
-- vim.cmd('colorscheme oxocarbon')
-- vim.g.sierra_Sunset = 1
vim.g.sierra_Twilight = 1
-- vim.g.sierra_Midnight = 1
-- vim.g.sierra_Pitch = 1
vim.cmd('colorscheme sierra')
-- vim.o.background = 'dark'

-- hide statusline
-- vim.cmd("set noshowmode")
-- vim.cmd("set noruler")
-- vim.cmd("set laststatus=0")
-- vim.cmd("set noshowcmd")

-- Indentation
Indenation(1)
vim.o.copyindent = true

-- Folds
vim.opt.foldmethod = "indent"
vim.opt.foldminlines = 2
vim.opt.foldnestmax = 4

-- Display
vim.o.signcolumn = "yes"
vim.o.hidden = true
vim.o.number = false
vim.o.cursorline = false
vim.o.showmatch = true

-- Search
vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- Text rendering
vim.o.scrolloff = 5

-- Autocmds
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   callback = function()
--     vim.lsp.buf.format()
--   end,
-- })

-- Misc
vim.o.autoread = true                          -- listen for file updates
vim.o.dir = os.getenv("HOME") .. "/.cache/vim" -- cache dir
vim.g.c_syntax_for_h = 1                       -- .h are c files

-- Highlights
vim.cmd('hi Normal          guibg=NONE')
vim.cmd('hi Normal          ctermbg=NONE')
-- vim.cmd('hi Comment         guifg=#9e9e9e')
-- vim.cmd('hi VertSplit       guifg=#d0d0d0 guibg=NONE')
-- vim.cmd('hi StatusLine      guibg=NONE')
-- vim.cmd('hi NonText         guifg=#5d7d8c')
-- vim.cmd('hi NeoTreeNormal   ctermbg=0')
-- vim.cmd('hi NeoTreeBorder   ctermbg=0')
-- vim.cmd('hi NeoTreeTitle    ctermbg=0')
-- vim.cmd('hi NeoTreeTitleBar ctermbg=0')
