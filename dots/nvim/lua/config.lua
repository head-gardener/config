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
vim.opt.foldlevelstart = 0
vim.opt.foldminlines = 2
vim.opt.foldnestmax = 7

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
