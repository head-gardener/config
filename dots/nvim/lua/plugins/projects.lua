return {
  {
    'akinsho/git-conflict.nvim',
    opts = {},
    keys = {
      { 'gco', ':GitConflictChooseOurs<cr>',   desc = 'Choose ours' },
      { 'gct', ':GitConflictChooseTheirs<cr>', desc = 'Choose theirs' },
      { 'gcb', ':GitConflictChooseBoth<cr>',   desc = 'Choose both' },
      { 'gcn', ':GitConflictChooseNone<cr>',   desc = 'Choose none' },
      { 'gcq', ':GitConflictListQf<cr>',       desc = 'Quickfix conflicts' },
      { ']x',  ':GitConflictPrevConflict<cr>', desc = 'Prev conflict' },
      { '[x',  ':GitConflictNextConflict<cr>', desc = 'Next conflict' },
    },
  },
  {
    'moyiz/git-dev.nvim',
    lazy = true,
    cmd = { "GitDevOpen", "GitDevToggleUI", "GitDevRecents", "GitDevCleanAll" },
    opts = {},
  },
  {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    init = function()
      vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'Identifier' })
      vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'Special' })
      vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { link = 'PreProc' })
      vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'Type' })
      vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { link = 'Constant' })
      vim.api.nvim_set_hl(0, 'GitSignsUntracked', { link = 'Underlined' })
    end,
    opts = {
      signs                        = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir                 = {
        interval = 1000,
        follow_files = true
      },
      attach_to_untracked          = true,
      current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority                = 6,
      update_debounce              = 100,
      status_formatter             = nil,   -- Use default
      max_file_length              = 40000, -- Disable if file is longer than this (in lines)
      preview_config               = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
    },
    keys = function()
      return {
        { '<Space>hs', ':Gitsigns stage_hunk<CR>', noremap = true },
        { '<Space>nh', ':Gitsigns next_hunk<CR>',  noremap = true },
        { '<Space>hr', ':Gitsigns reset_hunk<CR>', noremap = true },
      }
    end,
  },
  'direnv/direnv.vim',
}
