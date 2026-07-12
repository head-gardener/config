return {
  {
    'hrsh7th/nvim-cmp',
    event = 'VeryLazy',
    dependencies = { 'saadparwaiz1/cmp_luasnip' },
    init = function()
      local cmp = require('cmp')
      local ls = require('luasnip')

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            ls.lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<C-c>'] = cmp.mapping.complete({ "i", "s" }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif ls.expand_or_jumpable() then
              feedkey("<Plug>luasnip-expand-or-jump", "")
            else
              fallback()
            end
          end, { "i", "s", noremap = true }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif ls.jumpable(-1) then
              feedkey("<Plug>luasnip-jump-prev", "")
            else
              fallback()
            end
          end, { "i", "s" })
        },
        window = {
          completion = {
            border = 'rounded',
          },
          documentation = {
            border = 'rounded',
          },
        },
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end,
  },
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
}
