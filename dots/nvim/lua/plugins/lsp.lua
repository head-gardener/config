return {
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
  'psiska/telescope-hoogle.nvim',
  'LhKipp/nvim-nu',
  'nvimtools/none-ls.nvim',
  'ckolkey/ts-node-action',
  'camilledejoye/nvim-lsp-selection-range',
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^3',
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    enabled = false,
  },
  'mfussenegger/nvim-dap',
  {
    'someone-stole-my-name/yaml-companion.nvim',
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
  },
}
