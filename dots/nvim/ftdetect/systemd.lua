-- systemd units
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = {
    "*.mount",
    "*.path",
    "*.service",
    "*.slice",
    "*.socket",
    "*.target",
    "*.timer",
  },
  callback = function (ev)
    for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)) do
      if line == "[Unit]" then
        vim.cmd [[set filetype=systemd]]
        return
      end
    end
  end,
})
