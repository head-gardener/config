-- hide statusline
-- vim.cmd("set noshowmode")
-- vim.cmd("set noruler")
-- vim.cmd("set laststatus=0")
-- vim.cmd("set noshowcmd")

-- Indentation
Indenation(1)
vim.o.copyindent = true

-- Folds
vim.opt.foldlevelstart = 2
vim.opt.foldminlines = 2
vim.opt.foldnestmax = 7
vim.opt.fillchars = {
  fold = ' ',
}

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

local function spacesl(s)
  return string.gsub(s, "^(%s*).-$", "%1")
end

local function trim(s)
  return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

local function limit(s, n)
  if string.len(s) <= n then
    return s
  else
    return string.gsub(s, '^(' .. ('.'):rep(n) .. ').*$', '%1...')
  end
end

function MyFoldText()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart
  local count
  if line_count > 25 then
    count = string.rep("*", math.min(10, math.floor(line_count / 10)))
  else
    count = string.rep(".", line_count)
  end
  return line .. " => " .. count
end

vim.opt.foldtext = 'v:lua.MyFoldText()'

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'yaml', 'json' },
  callback = function()
    vim.opt.foldmethod = "indent"
  end,
})

-- Display
vim.o.signcolumn = "yes"
vim.o.hidden = true
vim.o.number = false
vim.o.cursorline = false
vim.o.showmatch = true
vim.opt.colorcolumn = { 90 }
vim.opt.title = true

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

-- Colors
-- vim.api.nvim_set_hl(0, 'TabLineFill', {fg = 'LightGreen', bg = 'DarkGreen'})
vim.cmd('set termguicolors')

-- Misc
vim.o.linebreak = true;
vim.o.exrc = true
vim.opt.undofile = true
vim.o.autoread = true                          -- listen for file updates
vim.o.dir = os.getenv("HOME") .. "/.cache/vim" -- cache dir
vim.g.c_syntax_for_h = 1                       -- .h are c files
