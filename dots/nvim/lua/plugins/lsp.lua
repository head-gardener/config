local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown" }
capabilities.textDocument.codeAction = {
  dynamicRegistration = true,
  codeActionLiteralSupport = {
    codeActionKind = {
      valueSet = (function()
        local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
        table.sort(res)
        return res
      end)(),
    },
  },
}

local lsp_signature_cfg = {
  handler_opts = {
    border = "rounded",
  },
  floating_window = false,
  doc_lines = 0,
  floating_window_off_x = 1,
  floating_window_off_y = -2,
  hint_prefix = ' |- ',
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

  require "lsp_signature".on_attach(lsp_signature_cfg, bufnr)

  bmap('n', '<space>e', vim.diagnostic.open_float)
  bmap('n', '[d', vim.diagnostic.goto_prev)
  bmap('n', ']d', vim.diagnostic.goto_next)
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
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = {},
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        underline = false,
        signs = true,
        update_in_insert = false,
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
        title = " Hover ",
      })

      lspconfig.nixd.setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      lspconfig.hls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      lspconfig.julials.setup {
        settings = {},
        capabilities = capabilities,
        on_attach = on_attach,
      }

      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            runtime = {
              path = vim.split(package.path, ';'),
            },
            diagnostics = {
              globals = { "vim", "describe", "it", "assert" },
            },
            workspace = {
              -- library = { os.getenv('HOME') .. 'Source/luassert/src/' },
            },
            telemetry = {
              enable = false,
            },
          },
        },
        capabilities = capabilities,
        on_attach = on_attach,
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {},
        auto_install = false,
        modules = {},
        sync_install = false,
        ignore_install = {},
        folding = {
          enable = true,
          persistent = true,
        },
        highlight = {
          enable = true,
          disable = {},
        },
      }
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
    'simrat39/rust-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', 'mfussenegger/nvim-dap',
    }
  },
  {
    'williamboman/mason.nvim',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = true,
    opts = {}
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
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
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
