return {
  {
    'm-demare/attempt.nvim',
    event = 'VeryLazy',
    keys = function()
      return {
        { '<leader>an', require('attempt').new_select,    desc = 'New attempt, selecting extension' },
        { '<leader>ai', require('attempt').new_input_ext, desc = 'New attempt, inputing extension' },
        { '<leader>ar', require('attempt').run,           desc = 'Run attempt' },
        { '<leader>ad', require('attempt').delete_buf,    desc = 'Delete attempt from current buffer' },
        { '<leader>ac', require('attempt').rename_buf,    desc = 'Rename attempt from current buffer' },
        { '<leader>al', '<cmd>Telescope attempt<cr>',     desc = 'Open attempts with Telescope' },
      }
    end,
    opts = {},
    init = function()
      require('telescope').load_extension('attempt')
    end,
  },
  {
    'moyiz/git-dev.nvim',
    lazy = true,
    cmd = { "GitDevOpen", "GitDevToggleUI", "GitDevRecents", "GitDevCleanAll" },
    opts = {},
  },
  {
    'Wansmer/sibling-swap.nvim',
    requires = { 'nvim-treesitter' },
    lazy = false,
    opts = {},
  },
  {
    'Wansmer/langmapper.nvim',
    lazy = false,
    priority = 1,
    config = function()
      require('langmapper').setup({})
      require('langmapper').hack_get_keymap()
    end,
    init = function()
      require('langmapper').automapping({ global = true, buffer = true })
    end
  },
  {
    'jumas-cola/cosco.nvim',
    keys = function()
      return {
        {
          "<Space>;",
          function() require("cosco").comma_or_semi_colon() end,
          noremap = true,
          silent = true,
          desc = "Auto comma or semicolon"
        }
      }
    end,
    lazy = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      'nvim-neorg/lua-utils.nvim',
      'pysan3/pathlib.nvim',
      'nvim-neotest/nvim-nio',
    },
    lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = true,
  },
  'chrisbra/improvedft',
  'ja-ford/delaytrain.nvim',
  'arthurxavierx/vim-unicoder',
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
      },
    },
  },
  'fladson/vim-kitty',
  {
    'karb94/neoscroll.nvim',
    opts = {
      hide_cursor = false,         -- Hide cursor while scrolling
      stop_eof = true,             -- Stop at <EOF> when scrolling downwards
      respect_scrolloff = true,    -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      easing_function = 'sine',    -- Default easing function
      pre_hook = nil,              -- Function to run before the scrolling animation starts
      post_hook = nil,             -- Function to run after the scrolling animation ends
      performance_mode = false,    -- Disable 'Performance Mode' on all buffers.
    },
  },
  'tpope/vim-endwise',
  'tpope/vim-surround',
  {
    'windwp/nvim-autopairs',
    opts = {
      check_ts = true,
    },
  },
  {
    'tpope/vim-commentary',
    keys = function()
      return {
        { '<C-/>', ':Commentary<CR>', mode = { 'n', 'v' }, noremap = true },
        -- alt keymap for tmux - it sends C-/ as C-_
        { '<C-_>', ':Commentary<CR>', mode = { 'n', 'v' }, noremap = true },
      }
    end,
  },
}
