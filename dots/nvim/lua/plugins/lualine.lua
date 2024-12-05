local colors = {
  lightgray = '#d6d6dd',
  gray = '#efede0',
  innerbg = nil,
  outerbg = nil,
  normal = '#5d7d8c',
  insert = '#778a60',
  visual = '#8c5d40',
  replace = '#e46876',
  command = '#3f6a55',
}

local clock = function()
  return os.date('%H:%M:%S')
end

local current_signature = function(width)
  if not pcall(require, 'lsp_signature') then return end
  local sig = require("lsp_signature").status_line(width)
  return sig.label
end

local cur_sig_wrapped = function()
  return current_signature(math.floor(vim.fn.winwidth(0) / 2))
end

return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enbled = false,
        theme = {
          inactive = {
            a = { fg = colors.gray, bg = colors.outerbg, gui = 'bold' },
            b = { fg = colors.gray, bg = colors.outerbg },
            c = { fg = colors.gray, bg = colors.innerbg },
          },
          visual = {
            a = { fg = colors.lightgray, bg = colors.visual, gui = 'bold' },
            b = { fg = colors.gray, bg = colors.outerbg },
            c = { fg = colors.gray, bg = colors.innerbg },
          },
          replace = {
            a = { fg = colors.lightgray, bg = colors.replace, gui = 'bold' },
            b = { fg = colors.gray, bg = colors.outerbg },
            c = { fg = colors.gray, bg = colors.innerbg },
          },
          normal = {
            a = { fg = colors.lightgray, bg = colors.normal, gui = 'bold' },
            b = { fg = colors.gray, bg = colors.outerbg },
            c = { fg = colors.gray, bg = colors.innerbg },
          },
          insert = {
            a = { fg = colors.lightgray, bg = colors.insert, gui = 'bold' },
            b = { fg = colors.gray, bg = colors.outerbg },
            c = { fg = colors.gray, bg = colors.innerbg },
          },
          command = {
            a = { fg = colors.lightgray, bg = colors.command, gui = 'bold' },
            b = { fg = colors.gray, bg = colors.outerbg },
            c = { fg = colors.gray, bg = colors.innerbg },
          },
        },
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { cur_sig_wrapped, 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'filetype' },
        lualine_y = { 'location' },
        lualine_z = { clock },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {
      },
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
}
