local prev_indent_preset = 1
local indentation_presets = {
  [1] = {
    apply = function()
      vim.o.tabstop = 2
      vim.o.softtabstop = 2
      vim.o.shiftwidth = 2
      vim.o.expandtab = true
    end,
    describe = function()
      return '2 spaces'
    end,
  },
  [2] = {
    apply = function()
      vim.o.tabstop = 8
      vim.o.softtabstop = 8
      vim.o.shiftwidth = 8
      vim.o.expandtab = false
    end,
    describe = function()
      return '8 tabs'
    end,
  },
  [3] = {
    apply = function()
      vim.o.tabstop = 4
      vim.o.softtabstop = 4
      vim.o.shiftwidth = 4
      vim.o.expandtab = false
    end,
    describe = function()
      return '4 tabs'
    end,
  },
  [4] = {
    apply = function()
      vim.o.tabstop = 2
      vim.o.softtabstop = 2
      vim.o.shiftwidth = 2
      vim.o.expandtab = false
    end,
    describe = function()
      return '2 tabs'
    end,
  },
}

-- Gets current highlight and somethings else idh
-- TODO: rewrite to lua and ugh make this work idk
vim.cmd([[
function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun]]
)

-- Source current buffer
vim.api.nvim_create_user_command('PSourceCurrent',
  function()
    local path = vim.api.nvim_buf_get_name(0)
    vim.cmd { cmd = 'source', args = { path }, }
    print('sourced :)')
  end,
  {})

-- Search arg on duckduckgo
LookUp = function(arg)
  os.execute('xdg-open https://duckduckgo.com/' .. arg)
end
vim.api.nvim_create_user_command('PSearch',
  function(opt)
    LookUp(opt.args)
  end,
  { nargs = '?' })

-- Opens a window listening for query for Search command
vim.api.nvim_create_user_command('PLookUp',
  function()
    -- initialize buffer
    local buffer = vim.api.nvim_create_buf(false, true)
    for i = 0, 4, 1 do
      vim.api.nvim_buf_add_highlight(buffer, -1, 'Normal', i, 0, -1)
    end

    -- initialize window
    local width = 40
    local height = 5
    local win_opts = {
      relative = 'win',
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      anchor = 'NW',
      style = 'minimal',
      border = 'rounded',
    }
    local win = vim.api.nvim_open_win(buffer, 0, win_opts)
    vim.api.nvim_win_set_cursor(win, { [1] = prev_indent_preset, [2] = 0 })

    -- TODO: set mode and improve looks
    -- generate bindings
    vim.api.nvim_buf_set_keymap(buffer, 'i', '<CR>', '',
      {
        callback = function()
          -- local pos = vim.api.nvim_win_get_cursor(win)[1]
          local query = vim.api.nvim_buf_get_lines(buffer, 0, 1, false)[1]
          print(query)
          LookUp(query)
          vim.api.nvim_win_close(win, false)
        end
      })
    vim.api.nvim_buf_set_keymap(buffer, 'i', '<Esc>', '',
      {
        callback = function()
          vim.api.nvim_win_close(win, false)
        end
      })
  end,
  {})

-- Cool little widget for configuring tabulation
-- TODO: make window transparent
vim.api.nvim_create_user_command('PSwitch',
  function()
    -- tools for highlighting a line
    local ns = vim.api.nvim_create_namespace('indent_widget')
    local highligh = function(buf, line, length)
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, length)
      for i = 0, length - 1, 1 do
        vim.api.nvim_buf_add_highlight(buf, ns, 'Normal', i, 0, -1)
      end
      vim.api.nvim_buf_add_highlight(buf, ns, 'Label', line - 1, 0, -1)
    end

    -- initialize description list
    local descriptions = {}
    local width = 0
    for i = 1, #indentation_presets, 1 do
      local description = '- ' .. indentation_presets[i].describe()
      if (string.len(description) > width) then
        width = string.len(description)
      end
      table.insert(descriptions, description)
    end
    width = width + 3

    -- initialize buffer
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, descriptions)
    vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
    vim.api.nvim_buf_set_option(buffer, 'modified', false)
    highligh(buffer, prev_indent_preset, #descriptions)

    -- initialize window
    local win_opts = {
      relative = 'win',
      width = width,
      height = #descriptions,
      col = (vim.o.columns - width) / 1.618,
      row = (vim.o.lines - #descriptions) / 2,
      anchor = 'NW',
      style = 'minimal',
      border = 'rounded',
    }
    local win = vim.api.nvim_open_win(buffer, 0, win_opts)
    vim.api.nvim_win_set_cursor(win, { [1] = prev_indent_preset, [2] = 0 })

    -- generate bindings
    local shift_highlight = function(offset)
      return function()
        local pos = vim.api.nvim_win_get_cursor(win)[1] + offset
        if (pos < 1) then
          pos = 1
        end
        if (pos > #descriptions) then
          pos = #descriptions
        end
        vim.api.nvim_win_set_cursor(win, { [1] = pos, [2] = 0 })
        highligh(buffer, pos, #descriptions)
      end
    end
    vim.api.nvim_buf_set_keymap(buffer, 'n', 'j', '',
      { callback = shift_highlight(1) })
    vim.api.nvim_buf_set_keymap(buffer, 'n', 'k', '',
      { callback = shift_highlight(-1) })
    vim.api.nvim_buf_set_keymap(buffer, 'n', 'h', '', {})
    vim.api.nvim_buf_set_keymap(buffer, 'n', 'l', '', {})
    vim.api.nvim_buf_set_keymap(buffer, 'n', '<CR>', '',
      {
        callback = function()
          local pos = vim.api.nvim_win_get_cursor(win)[1]
          vim.api.nvim_win_close(win, false)
          Indenation(pos)
        end
      })
    vim.api.nvim_buf_set_keymap(buffer, 'n', '<Esc>', '',
      {
        callback = function()
          vim.api.nvim_win_close(win, false)
        end
      })
  end,
  {})

-- Sets indentation settings according to chosen preset
Indenation = function(preset)
  local preset_entry = indentation_presets[preset]
  if (preset_entry) then
    preset_entry.apply()
    prev_indent_preset = preset
  else
    print "Invalid indentation preset!"
  end
end
