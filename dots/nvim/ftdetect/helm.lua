vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = {
    "*.tpl",
    "*.txt",
    "*.yaml",
    "*.yml",
  },
  callback = function (ev)
    local parts = vim.split(ev.match, '/templates/', { plain = true, trimempty = true })
    if #parts <= 1 then
      return
    end
    for i = #parts - 1, 1, -1 do
      local full = table.concat(vim.list_slice(parts, 1, i), '/templates/') .. '/Chart.yaml'
      if vim.fn.filereadable(full) == 1 then
        vim.cmd [[set filetype=helm]]
        return
      end
    end
  end,
})
