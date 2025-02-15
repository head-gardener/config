vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = {
    "docker-compose.yaml*",
    "docker-compose.yml*",
    "compose.yaml*",
    "compose.yml*",
  },
  command = 'set filetype=yaml.docker-compose',
})
