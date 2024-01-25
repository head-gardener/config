require('lazy').setup({
  -- project mng
  'lewis6991/gitsigns.nvim',

  -- deps
  'nvim-lua/plenary.nvim',

  -- themes
  'ellisonleao/gruvbox.nvim',
  'AlessandroYorba/Sierra',

  -- lsp/cmp
  'neovim/nvim-lspconfig',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'nvim-treesitter/nvim-treesitter',
  {
    'E-ricus/lsp_codelens_extensions.nvim',
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" }
  },
  {
    'simrat39/rust-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', 'mfussenegger/nvim-dap',
    }
  },
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',

  -- snippets
  'hrsh7th/vim-vsnip',
  'hrsh7th/cmp-vsnip',

  -- ui
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  },
  'hkupty/iron.nvim',
  'folke/zen-mode.nvim',
  'folke/twilight.nvim',
  'folke/todo-comments.nvim',
  'enddeadroyal/symbols-outline.nvim',
  'srstevenson/vim-picker',

  -- misc
  'head-gardener/catalyst',
  'chrisbra/improvedft',
  'ja-ford/delaytrain.nvim',
  {
    "tversteeg/registers.nvim",
    config = function()
      require("registers").setup()
    end,
  },
  'folke/neodev.nvim',
  'fladson/vim-kitty',
  'yamatsum/nvim-cursorline',
  'karb94/neoscroll.nvim',
  'tpope/vim-endwise',
  'tpope/vim-surround',
  'windwp/nvim-autopairs',
  'tpope/vim-commentary',
})
