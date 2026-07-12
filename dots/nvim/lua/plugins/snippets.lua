return {
  {
    'L3MON4D3/LuaSnip',
    build = (not jit.os:find('Windows')) and 'make install_jsregexp' or nil,
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
    config = function(_, opts)
      local ls = require('luasnip')
      ls.setup(opts)
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = { vim.fn.stdpath('config') .. '/vssnippets' },
      })

      -- vscode snippet packages supplied via the home-manager wrapper
      -- (colon-separated store paths in NVIM_VSCODE_SNIPPET_PATHS).
      local env_paths = vim.env.NVIM_VSCODE_SNIPPET_PATHS
      if env_paths and env_paths ~= "" then
        for _, p in ipairs(vim.split(env_paths, ":")) do
          if p ~= "" and vim.fn.isdirectory(p) == 1 then
            require('luasnip.loaders.from_vscode').lazy_load({ paths = { p } })
          end
        end
      end
    end,
  },
}
