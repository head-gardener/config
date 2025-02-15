local function align_equals(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local node = vim.treesitter.get_node()
  if not node then
    return
  end

  local block_node = nil
  local current = node
  while current do
    if current:type() == "block" then
      block_node = current
      break
    end
    current = current:parent()
  end

  if not block_node then
    return
  end

  local start_row, _, end_row, _ = block_node:range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, false)
  vim.print(lines);

  local max_col = 0
  for _, line in ipairs(lines) do
    local col = string.find(line, "=")
    if col then
      max_col = math.max(max_col, col)
    end
  end

  local new_lines = {}
  for _, line in ipairs(lines) do
    local col = string.find(line, "=")
    if col then
      local indent = string.rep(" ", max_col - col)
      new_lines[#new_lines + 1] = string.sub(line, 1, col - 1) .. indent .. string.sub(line, col)
    else
      new_lines[#new_lines + 1] = line
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row, false, new_lines)
end

vim.keymap.set({ 'n' }, '<localleader>l', align_equals, { desc = 'Level HCL objects' })
vim.bo.commentstring = '# %s'
