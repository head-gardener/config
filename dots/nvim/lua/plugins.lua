require('lazy').setup({
  -- project mng
  'lewis6991/gitsigns.nvim',
  'direnv/direnv.vim',

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
  'psiska/telescope-hoogle.nvim',
  'LhKipp/nvim-nu',
  'nvimtools/none-ls.nvim',
  'ckolkey/ts-node-action',
  'camilledejoye/nvim-lsp-selection-range',
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^3',
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  },
  'mfussenegger/nvim-dap',

  -- snippets
  'hrsh7th/vim-vsnip',
  'hrsh7th/cmp-vsnip',

  -- ui
  { 'sindrets/diffview.nvim', lazy = false },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  'hkupty/iron.nvim',
  'folke/zen-mode.nvim',
  'folke/twilight.nvim',
  'folke/todo-comments.nvim',
  'enddeadroyal/symbols-outline.nvim',
  'srstevenson/vim-picker',
  'nvim-telescope/telescope.nvim',
  {
    enabled = true,
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = { 'Wansmer/langmapper.nvim' },
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300

      -- needed for binds to work with langmapper
      local lmu = require('langmapper.utils')
      local view = require('which-key.view')
      local execute = view.execute

      -- wrap `execute()` and translate sequence back
      view.execute = function(prefix_i, mode, buf)
        -- Translate back to English characters
        prefix_i = lmu.translate_keycode(prefix_i, 'default', 'ru')
        execute(prefix_i, mode, buf)
      end

      require('which-key').setup()
    end
  },
  {
    'brenoprata10/nvim-highlight-colors',
    lazy = true,
    cmd = 'HighlightColors',
    config = function ()
      vim.api.nvim_command('set t_Co=256')
      require('nvim-highlight-colors').setup {}
    end,
  },

  -- misc
  {
    'Wansmer/sibling-swap.nvim',
    requires = { 'nvim-treesitter' },
    lazy = false,
    config = function()
      require('sibling-swap').setup({ --[[ your config ]] })
    end,
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
    build = ":Neorg sync-parsers",
    lazy = false,
    -- tag = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond",
          },
        },
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/notes",
            },
          },
        },
        ["core.export"] = {
          -- config = { export_dir = "./build" },
        },
      },
    }
  },
  'chrisbra/improvedft',
  'ja-ford/delaytrain.nvim',
  'folke/neodev.nvim',
  'fladson/vim-kitty',
  'yamatsum/nvim-cursorline',
  'karb94/neoscroll.nvim',
  'tpope/vim-endwise',
  'tpope/vim-surround',
  'windwp/nvim-autopairs',
  'tpope/vim-commentary',
}, {
})
