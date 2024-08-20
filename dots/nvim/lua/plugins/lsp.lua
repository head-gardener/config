return {
  'neovim/nvim-lspconfig',
  {
    'hrsh7th/nvim-cmp',
    event = 'VeryLazy',
    init = function()
      local cmp = require('cmp')

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            else
              fallback()
            end
          end, { "i", "s", noremap = true }),
          ['<S-Tab>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" })
        },
      })
    end,
  },
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {},
      sync_install = false,
      ignore_install = {},
      highlight = {
        enable = true,
        disable = {},
      },
    },
  },
  {
    'E-ricus/lsp_codelens_extensions.nvim',
    opts = {
      vertical_split = false,
      rust_debug_adapter = 'codelldb',
      init_rust_commands = true,
    },
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
}
