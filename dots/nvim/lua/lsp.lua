local lspconfig = require('lspconfig')
local lsp_selection_range = require('lsp-selection-range')
local null_ls = require('null-ls')
local ht = require('haskell-tools')
local dap = require('dap')

dap.adapters.haskell = {
  type = 'executable';
  command = 'haskell-debug-adapter';
}
dap.configurations.haskell = {
  {
    type = 'haskell',
    request = 'launch',
    name = 'Debug',
    workspace = '${workspaceFolder}',
    startup = "${file}",
    stopOnEntry = true,
    logFile = vim.fn.stdpath('data') .. '/haskell-dap.log',
    logLevel = 'WARNING',
    ghciEnv = vim.empty_dict(),
    ghciPrompt = "λ: ",
    -- Adjust the prompt to the prompt you see when you invoke the stack ghci command below
    ghciInitialPrompt = "λ: ",
    ghciCmd= "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
  },
}

local _bmap = function(bufnr)
  return function(mode, lhs, rhs, options)
    options = options or { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

local on_attach = function(_, bufnr)
  local bmap = _bmap(bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  bmap('n', 'vv', lsp_selection_range.trigger)
  bmap('v', 'vv', lsp_selection_range.expand)
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

vim.g.haskell_tools = {
  -- tools = {},
  hls = {
    on_attach = function(client, bufnr, _)
      local bmap = _bmap(bufnr)
      bmap('n', '<space>cl', vim.lsp.codelens.run)
      bmap('n', '<space>hs', ht.hoogle.hoogle_signature)
      bmap('n', '<space>ea', ht.lsp.buf_eval_all)
      on_attach(client, bufnr)
    end,
  },
  -- dap = {},
}

null_ls.setup {
  on_attach = on_attach,
  sources = {
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.code_actions.proselint,
    null_ls.builtins.code_actions.refactoring,
    null_ls.builtins.code_actions.statix,
    null_ls.builtins.code_actions.ts_node_action,
    null_ls.builtins.diagnostics.deadnix,
    null_ls.builtins.diagnostics.dotenv_linter,
    null_ls.builtins.diagnostics.editorconfig_checker,
  }
}

local capabilities = lsp_selection_range.update_capabilities(
  require('cmp_nvim_lsp').default_capabilities()
)
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.nixd.setup {
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
  end,
}
