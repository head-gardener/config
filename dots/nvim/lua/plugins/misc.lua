return {
  {
    'm-demare/attempt.nvim',
    event = 'VeryLazy',
    keys = function()
      return {
        { '<leader>an', require('attempt').new_select, desc = 'New attempt, selecting extension' },
        { '<leader>ai', require('attempt').new_input_ext, desc = 'New attempt, inputing extension' },
        { '<leader>ar', require('attempt').run, desc = 'Run attempt' },
        { '<leader>ad', require('attempt').delete_buf, desc = 'Delete attempt from current buffer' },
        { '<leader>ac', require('attempt').rename_buf, desc = 'Rename attempt from current buffer' },
        { '<leader>al', '<cmd>Telescope attempt<cr>', desc = 'Open attempts with Telescope' },
      }
    end,
    opts = {},
    init = function()
      require('telescope').load_extension('attempt')
    end,
  },
  {
    'moyiz/git-dev.nvim',
    lazy = true,
    cmd = { "GitDevOpen", "GitDevToggleUI", "GitDevRecents", "GitDevCleanAll" },
    opts = {},
  },
  {
    'Wansmer/sibling-swap.nvim',
    requires = { 'nvim-treesitter' },
    lazy = false,
    opts = {},
  },
  {
    'Wansmer/langmapper.nvim',
    lazy = false,
    priority = 1,
    config = function()
      require('langmapper').setup({})
      require('langmapper').hack_get_keymap()
    end,
    init = function()
      require('langmapper').automapping({ global = true, buffer = true })
    end
  },
  {
    'jumas-cola/cosco.nvim',
    lazy = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      'nvim-neorg/lua-utils.nvim',
      'pysan3/pathlib.nvim',
      'nvim-neotest/nvim-nio',
    },
    lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = true,
  },
  'chrisbra/improvedft',
  'ja-ford/delaytrain.nvim',
  'arthurxavierx/vim-unicoder',
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
      },
    },
  },
  'fladson/vim-kitty',
  'yamatsum/nvim-cursorline',
  'karb94/neoscroll.nvim',
  'tpope/vim-endwise',
  'tpope/vim-surround',
  'windwp/nvim-autopairs',
  'tpope/vim-commentary',
}
