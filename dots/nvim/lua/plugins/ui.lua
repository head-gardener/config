return {
  {
    'xiyaowong/transparent.nvim',
    lazy = false,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    enabled = false,
    keys = {
      { "<leader>nd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss Noice messages" },
    },
    opts = {
      cmdline = {
        enabled = false,
        view = "cmdline",
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      popupmenu = { enabled = false, },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = false,        -- use a classic bottom cmdline for search
        command_palette = false,      -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000"
    },
  },
  {
    'ellisonleao/glow.nvim',
    config = true,
    cmd = "Glow"
  },
  { 'sindrets/diffview.nvim', lazy = false },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  'hkupty/iron.nvim',
  'folke/zen-mode.nvim',
  'folke/twilight.nvim',
  'folke/todo-comments.nvim',
  'enddeadroyal/symbols-outline.nvim',
  'srstevenson/vim-picker',
  'nvim-telescope/telescope.nvim',
  {
    enabled = true,
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = { 'Wansmer/langmapper.nvim' },
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      -- needed for binds to work with langmapper
      local lmu = require('langmapper.utils')
      local view = require('which-key.view')
      local execute = view.execute
      -- wrap `execute()` and translate sequence back
      view.execute = function(prefix_i, mode, buf)
        -- Translate back to English characters
        prefix_i = lmu.translate_keycode(prefix_i, 'default', 'ru')
        execute(prefix_i, mode, buf)
      end
      require('which-key').setup()
    end
  },
  {
    'brenoprata10/nvim-highlight-colors',
    lazy = true,
    cmd = 'HighlightColors',
    config = function()
      vim.api.nvim_command('set t_Co=256')
      require('nvim-highlight-colors').setup {}
    end,
  },
}
