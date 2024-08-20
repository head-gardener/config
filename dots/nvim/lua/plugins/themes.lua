return {
  {
    'ellisonleao/gruvbox.nvim',
    enabled = false,
  },
  {
    'AlessandroYorba/Sierra',
    init = function()
      -- vim.g.sierra_Sunset = 1
      vim.g.sierra_Twilight = 1
      -- vim.g.sierra_Midnight = 1
      -- vim.g.sierra_Pitch = 1
      vim.cmd('colorscheme sierra')
      -- vim.o.background = 'dark'
    end,
  },
}
