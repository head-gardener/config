local lspconfig = require('lspconfig')

local bufopts = { noremap = true, silent = true, buffer = bufnr }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, bufopts)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
vim.keymap.set({ 'n', 'i' }, '<C-s>', vim.lsp.buf.signature_help, bufopts)
vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
vim.keymap.set('n', '<space>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, bufopts)
vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
vim.keymap.set('n', '<space>a', vim.lsp.buf.code_action, bufopts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

vim.keymap.set('n', '<space>f', function()
  vim.lsp.buf.format { async = true }
end, bufopts)

local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.hls.setup {
  capabilities = capabilities;
}

lspconfig.nixd.setup {
  capabilities = capabilities;
}

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
  function(server_name)
    require("lspconfig")[server_name].setup {
      capabilities = capabilities,
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
            library = { os.getenv('HOME') .. 'Source/luassert/src/' },
          },
          telemetry = {
            enable = false,
          },
        },
      },
      cmd = { 'lua-language-server' },
      capabilities = capabilites,
    }
  end,
}
