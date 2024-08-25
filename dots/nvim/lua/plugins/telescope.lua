return {
  {
    'nvim-telescope/telescope.nvim',
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'TelescopeResults',
        command = [[setlocal nofoldenable]]
      })
    end,
    config = function()
      require('telescope').setup {
        defaults = require('telescope.themes').get_ivy {},
        extensions = {
          hoogle = {
            render = 'default',
            renders = {
              treesitter = {
                remove_wrap = false
              }
            }
          },
          file_browser = {
            hijack_netrw = true,
          },
        },
      }
    end,
    keys = function()
      local tbuiltin = require('telescope.builtin')
      return {
        { '<Leader>fo', ":Telescope hoogle list<CR>",  noremap = true, desc = 'Telescope hoogle search' },
        { '<Leader>fc', ":Telescope builtin<CR>",      noremap = true, desc = 'Telescope commands' },
        { '<Leader>ff', tbuiltin.find_files,           noremap = true, desc = "Telescope find file" },
        { '<Leader>fr', tbuiltin.buffers,              noremap = true, desc = "Telescope buffers" },
        { '<Leader>fg', tbuiltin.live_grep,            noremap = true, desc = "Telescope live grep" },
        { '<Leader>fd', ":Telescope diagnostics<CR>",  noremap = true, desc = "Telescope diagnostics" },
        { '<Leader>fb', ":Telescope file_browser<CR>", noremap = true, desc = "Telescope file browser" },
        { '<Leader>fh', tbuiltin.help_tags,            noremap = true, desc = "Telescope help tags" },
        { '<Leader>ft', tbuiltin.treesitter,           noremap = true, desc = "Telescope treesitter search" },
      }
    end,
  },
  {
    'psiska/telescope-hoogle.nvim',
    init = function()
      require('telescope').load_extension('hoogle')
    end,
  },
  {
    'someone-stole-my-name/yaml-companion.nvim',
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    init = function()
      require("telescope").load_extension("yaml_schema")

      -- some snippets here: https://github.com/budimanjojo/k8s-snippets/blob/master/snippets/k8s_io-api.json
      local cfg = require("yaml-companion").setup({
        -- lspconfig = {
        --   cmd = {"yaml-language-server"}
        -- },
      })
      require('lspconfig').yamlls.setup(cfg)
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    init = function()
      require('telescope').load_extension('file_browser')
    end,
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
}
