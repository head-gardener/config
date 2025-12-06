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
        defaults = require('telescope.themes').get_ivy {
          mappings = {
            i = {
              ["<c-j>"] = require("telescope.actions").select_default,
            },
          },
          vimgrep_arguments = {
            "rg",
            "--hidden",
            "--glob", "!**/.git/*",
            "--color=never",
            "--no-heading",
            "--follow",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--trim"
          }
        },
        extensions = {
          hoogle = {
            render = 'default',
            renders = {
              treesitter = {
                remove_wrap = false
              }
            }
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
        { '<Leader>fs', tbuiltin.git_status,           noremap = true, desc = "Telescope git status" },
        { '<Leader>fg', tbuiltin.live_grep,            noremap = true, desc = "Telescope live grep" },
        { '<Leader>fd', ":Telescope diagnostics<CR>",  noremap = true, desc = "Telescope diagnostics" },
        { '<Leader>fb', ":Telescope file_browser<CR>", noremap = true, desc = "Telescope file browser" },
        { '<Leader>fh', tbuiltin.help_tags,            noremap = true, desc = "Telescope help tags" },
        { '<Leader>ft', tbuiltin.treesitter,           noremap = true, desc = "Telescope treesitter search" },
        { '<Leader>fl', tbuiltin.resume,               noremap = true, desc = "Telescope open last search" },
        { '<leader>fp', tbuiltin.diagnostics,          noremap = true, desc = "Telescope diagnostics" },
        { 'gr',         tbuiltin.lsp_references,       noremap = true, desc = "Telescope lsp references" },
        { 'gd',         tbuiltin.lsp_definitions,      noremap = true, desc = "Telescope lsp definitions" },
        { '<space>d',   tbuiltin.lsp_type_definitions, noremap = true, desc = "Telescope lsp type definitions" },
      }
    end,
  },
  {
    'psiska/telescope-hoogle.nvim',
    enabled = false,
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
      vim.lsp.enable('yamlls')
      vim.lsp.config('yamlls', cfg)
    end,
  },
}
