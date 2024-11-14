vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false

vim.keymap.set('n', 'gp', function()
  local current_file = vim.fn.expand("%")

  if string.match(current_file, "_test%.go$") then
    vim.cmd("e " .. string.gsub(current_file, "_test", ""))
  else
    vim.cmd("e " .. string.gsub(current_file, ".go", "_test.go"))
  end
end, {
  noremap = true,
  buffer = true,
  -- silent = true,
  desc = 'Go to pair'
})
