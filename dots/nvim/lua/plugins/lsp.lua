local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- TODO: review this
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
capabilities.textDocument.completion.completionItem.documentationFormat = {
  "markdown",
  "plaintext"
}

local _bmap = function(bufnr)
  return function(mode, lhs, rhs, options)
    options = options or { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

local on_attach = function(client, bufnr)
  local bmap = _bmap(bufnr)

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  bmap('n', '<space>e', vim.diagnostic.open_float)
  bmap('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end)
  bmap('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end)
  bmap('n', '<space>q', vim.diagnostic.setloclist)
  bmap('n', 'gD', vim.lsp.buf.declaration)
  bmap('n', 'K', vim.lsp.buf.hover)
  bmap({ 'n', 'i' }, '<C-s>', vim.lsp.buf.signature_help)
  bmap('n', '<space>rn', vim.lsp.buf.rename)
  bmap('n', '<space>a', vim.lsp.buf.code_action)
  bmap('n', '<space>f', function()
    vim.lsp.buf.format { async = true }
  end)
end

return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      vim.diagnostic.config({
        underline = false,
        signs = true,
        update_in_insert = false,
        severity_sort = true,

        virtual_text = true,
        virtual_lines = false,

        jump = {
          on_jump = function(_, bufnr)
            vim.diagnostic.open_float {
              bufnr = bufnr,
              scope = 'cursor',
              focus = false,
            }
          end,
        },
      })

      vim.lsp.config('*', {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      vim.lsp.config('nixd', {})
      vim.lsp.enable('nixd')

      vim.lsp.enable('pyright')

      vim.lsp.config('hls', {
        settings = {
          haskell = {
            plugin = {
              ['ghcide-code-actions-fill-holes'] = {
                globalOn = true,
              },
              ['ghcide-completions'] = {
                globalOn = true,
              },
              ['ghcide-hover-and-symbols'] = {
                globalOn = true,
              },
              ["ghcide-type-lenses"] = {
                globalOn = true,
              },
              ["ghcide-code-actions-type-signatures"] = {
                globalOn = true,
              },
              ["ghcide-code-actions-bindings"] = {
                globalOn = true,
              },
              ["ghcide-code-actions-imports-exports"] = {
                globalOn = true,
              },
              eval = {
                globalOn = true,
              },
              ["explicit-fields"] = {
                globalOn = false,
              },
              moduleName = {
                globalOn = true,
              },
              pragmas = {
                globalOn = true,
              },
              importLens = {
                globalOn = false,
              },
              class = {
                globalOn = true,
              },
              hlint = {
                globalOn = false,
              },
              retrie = {
                globalOn = true,
              },
              rename = {
                globalOn = true,
              },
              splice = {
                globalOn = true,
              },
              stan = {
                globalOn = true,
              },
              signatureHelp = {
                globalOn = false,
              },
            }
          }
        }
      })
      vim.lsp.enable('hls')

      vim.lsp.config('julials', {})
      vim.lsp.enable('julials')

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = {
              path = vim.split(package.path, ';'),
            },
            diagnostics = {
              globals = { "vim", "describe", "it", "assert" },
            },
            workspace = {
              library = {
                '/run/current-system/sw/share/awesome/lib',
                '/run/current-system/sw/share/nvim/runtime/lua',
                '/run/current-system/sw/share/nvim/runtime/lua/lsp',
              },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
      vim.lsp.enable('lua_ls')

      vim.lsp.config('ts_ls', {
        root_markers = {
          'tsconfig.json',
          '.git',
        },
      })
      vim.lsp.enable('ts_ls')
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    config = function()
      require('nvim-treesitter').setup {}

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          if not pcall(vim.treesitter.start) then
            return
          end
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'
        end,
      })
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lsp_cfg = {
        capabilities = capabilities,
        on_attach = on_attach,
      }
    },
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
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
    'mason-org/mason.nvim',
    lazy = false,
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    enabled = true,
    opts = { },
    lazy = false,
    dependencies = {
      "neovim/nvim-lspconfig",
      "mason-org/mason.nvim",
    },
  },
  'LhKipp/nvim-nu',
  {
    'nvimtools/none-ls.nvim',
    enabled = false,
    init = function()
      local null_ls = require('null-ls')
      null_ls.setup {
        on_attach = on_attach,
        sources = {
          null_ls.builtins.code_actions.gitsigns,
        }
      }
    end,
  },
  'ckolkey/ts-node-action',
  'camilledejoye/nvim-lsp-selection-range',
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^3',
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    enabled = false,
    init = function()
      local ht = require('haskell-tools')

      vim.g.haskell_tools = {
        -- tools = {},
        hls = {
          on_attach = function(client, bufnr, _)
            local bmap = _bmap(bufnr)
            bmap('n', '<space>cl', vim.lsp.codelens.run)
            bmap('n', '<space>ea', ht.lsp.buf_eval_all)
            on_attach(client, bufnr)
          end,
        },
        -- dap = {},
      }
    end,
  },
  'mfussenegger/nvim-dap',
}
