require('lazy').setup({
  -- project mng
  'lewis6991/gitsigns.nvim',
  'direnv/direnv.vim',

  -- deps
  'nvim-lua/plenary.nvim',
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },

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

  -- snippets
  'hrsh7th/vim-vsnip',
  'hrsh7th/cmp-vsnip',

  -- ui
  {
    'xiyaowong/transparent.nvim',
    lazy = false,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    enabled = false,
    keys = {
      { "<leader>nd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss Noice messages" },
    },
    opts = {
      cmdline = {
        enabled = false,
        view = "cmdline",
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      popupmenu = { enabled = false, },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = false,        -- use a classic bottom cmdline for search
        command_palette = false,      -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000"
    },
  },
  {
    'ellisonleao/glow.nvim',
    config = true,
    cmd = "Glow"
  },
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
    config = function()
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
}, {
})
