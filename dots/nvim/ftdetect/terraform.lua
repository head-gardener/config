vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.tf" },
  command = 'set filetype=hcl',
})
