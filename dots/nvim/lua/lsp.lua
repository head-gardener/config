local lspconfig = require('lspconfig')
local null_ls = require('null-ls')

local on_attach = function(client, bufnr)
  local bmap = function(mode, lhs, rhs, options)
    options = options or { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set(mode, lhs, rhs, options)
  end

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  bmap('n', '<space>e', vim.diagnostic.open_float)
  bmap('n', '[d', vim.diagnostic.goto_prev)
  bmap('n', ']d', vim.diagnostic.goto_next)
  bmap('n', '<space>q', vim.diagnostic.setloclist)
  bmap('n', 'gD', vim.lsp.buf.declaration)
  bmap('n', 'gd', vim.lsp.buf.definition)
  bmap('n', 'K', vim.lsp.buf.hover)
  bmap('n', 'gi', vim.lsp.buf.implementation)
  bmap({ 'n', 'i' }, '<C-s>', vim.lsp.buf.signature_help)
  bmap('n', '<space>D', vim.lsp.buf.type_definition)
  bmap('n', '<space>rn', vim.lsp.buf.rename)
  bmap('n', '<space>a', vim.lsp.buf.code_action)
  bmap('n', 'gr', vim.lsp.buf.references)
  bmap('n', '<space>f', function()
    vim.lsp.buf.format { async = true }
  end)
end

null_ls.setup{
  on_attach = on_attach,
  sources = {
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.code_actions.proselint,
    null_ls.builtins.code_actions.refactoring,
    null_ls.builtins.code_actions.statix,
    null_ls.builtins.code_actions.ts_node_action,
    null_ls.builtins.completion.spell,
    null_ls.builtins.diagnostics.commitlint,
    null_ls.builtins.diagnostics.deadnix,
    null_ls.builtins.diagnostics.dotenv_linter,
    null_ls.builtins.diagnostics.editorconfig_checker,
  }
}

capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.nixd.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
    }
  end,
  ["rust_analyzer"] = function()
    local rt = require("rust-tools")
    rt.setup {
      server = {
        on_attach = function(_, bufnr)
          local bufopts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "K", rt.hover_actions.hover_actions, bufopts)
          vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, bufopts)
          vim.keymap.set("n", "<M-r>", rt.runnables.runnables, bufopts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
          vim.keymap.set({ 'n', 'i' }, '<M-s>', vim.lsp.buf.signature_help, bufopts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
          vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
        end,
      },
    }
  end,
  ["lua_ls"] = function()
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
      cmd = { 'lua-language-server' },
      capabilities = capabilites,
      on_attach = on_attach,
    }
  end,
}
