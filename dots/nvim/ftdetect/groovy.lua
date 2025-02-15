vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "jenkinsfile", "Jenkinsfile" },
  command = 'set filetype=groovy',
})
