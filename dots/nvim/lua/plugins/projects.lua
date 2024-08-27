return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require('harpoon')

      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        }):find()
      end

      return {
        { "<space>ha", function() harpoon:list():add() end,             desc = "Harpoon add" },
        { "<space>hh", function() harpoon:list():select(1) end,         desc = "Harpoon select first" },
        { "<space>hj", function() harpoon:list():select(2) end,         desc = "Harpoon select second" },
        { "<space>hk", function() harpoon:list():select(3) end,         desc = "Harpoon select third" },
        { "<space>hl", function() harpoon:list():select(4) end,         desc = "Harpoon select fourth" },
        { "<space>hrh", function() harpoon:list():replace_at(1) end,         desc = "Harpoon replace first" },
        { "<space>hrj", function() harpoon:list():replace_at(2) end,         desc = "Harpoon replace second" },
        { "<space>hrk", function() harpoon:list():replace_at(3) end,         desc = "Harpoon replace third" },
        { "<space>hrl", function() harpoon:list():replace_at(4) end,         desc = "Harpoon replace fourth" },
        { "<leader>fa", function() toggle_telescope(harpoon:list()) end, desc = "Telescope harpoon" },
      }
    end
  },
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
    opts = {
      git = {
        base_uri_format = "https://github.com/%s.git",
        clone_args = "--jobs=2 --single-branch --recurse-submodules "
            .. "--shallow-submodules --progress --depth 1",
        fetch_args = "--jobs=2 --no-all --update-shallow -f --prune --no-tags"
            .. "--depth 1",
        checkout_args = "-f --recurse-submodules",
      },
    },
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
      }
    end,
  },
  'direnv/direnv.vim',
}
