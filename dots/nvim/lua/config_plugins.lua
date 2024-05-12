-- Colorscheme
vim.cmd('set termguicolors')
-- vim.cmd('colorscheme gruvbox')
-- vim.cmd('colorscheme oxocarbon')
-- vim.g.sierra_Sunset = 1
vim.g.sierra_Twilight = 1
-- vim.g.sierra_Midnight = 1
-- vim.g.sierra_Pitch = 1
vim.cmd('colorscheme sierra')
-- vim.o.background = 'dark'

-- Highlights
vim.cmd('hi Normal          guibg=NONE')
vim.cmd('hi Normal          ctermbg=NONE')
-- vim.cmd('hi Comment         guifg=#9e9e9e')
-- vim.cmd('hi VertSplit       guifg=#d0d0d0 guibg=NONE')
-- vim.cmd('hi StatusLine      guibg=NONE')
-- vim.cmd('hi NonText         guifg=#5d7d8c')
-- vim.cmd('hi NeoTreeNormal   ctermbg=0')
-- vim.cmd('hi NeoTreeBorder   ctermbg=0')
-- vim.cmd('hi NeoTreeTitle    ctermbg=0')
-- vim.cmd('hi NeoTreeTitleBar ctermbg=0')

vim.cmd [[highlight NotifyDEBUGBorder guifg=#3a877e]]
vim.cmd [[highlight NotifyDEBUGIcon guifg=#686995]]
vim.cmd [[highlight NotifyDEBUGTitle guifg=#686995]]
vim.cmd [[highlight NotifyERRORBorder guifg=#a95059]]
vim.cmd [[highlight NotifyERRORIcon guifg=#d28484]]
vim.cmd [[highlight NotifyERRORTitle guifg=#d28484]]
vim.cmd [[highlight NotifyINFOBorder guifg=#38776e]]
vim.cmd [[highlight NotifyINFOIcon guifg=#3a877e]]
vim.cmd [[highlight NotifyINFOTitle guifg=#3a877e]]
vim.cmd [[highlight NotifyTRACEBorder guifg=#242424]]
vim.cmd [[highlight NotifyTRACEIcon guifg=#343434]]
vim.cmd [[highlight NotifyTRACETitle guifg=#343434]]
vim.cmd [[highlight NotifyWARNBorder guifg=#9f7b7b]]
vim.cmd [[highlight NotifyWARNIcon guifg=#aa5c5c]]
vim.cmd [[highlight NotifyWARNTitle guifg=#aa5c5c]]

local function clock()
  return os.date("%H:%M:%S")
end

require'nu'.setup{}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopeResults",
  command = [[setlocal nofoldenable]]
})
require("telescope").setup {
  defaults = require('telescope.themes').get_ivy {

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
    file_browser = {
      hijack_netrw = true,
    },
  },
}

require('telescope').load_extension('hoogle')
require('telescope').load_extension('file_browser')

require('neoscroll').setup({
  hide_cursor = false,         -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = true,    -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  easing_function = "sine",    -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
})

---@diagnostic disable-next-line: unused-function, unused-local
local function arrowheads(val, rev)
  local stage = 3
  local shift = 1
  if not rev then
    shift = -1
  end
  local str = val .. '  ' .. val .. '  ' .. val .. '  ' .. val

  return function()
    stage = stage + shift
    if stage > 3 then
      stage = 1
    end
    if stage < 1 then
      stage = 3
    end

    return string.sub(str, stage, stage + 6)
  end
end

require('nvim-cursorline').setup {
  cursorline = {
    enable = false,
    timeout = 1000,
    number = true,
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
}

local iron = require("iron.core")

iron.setup {
  config = {
    scratch_repl = true,
    repl_definition = {
      sh = {
        command = { "fish" }
      },
      rust = {
        command = { "fish" }
      },
      haskell = {
        command = { "cabal", "repl" }
      },
      nix = {
        command = { "nix", "repl" }
      }
    },
    repl_open_cmd = require('iron.view').split.vertical.topleft(50),
  },
  -- Iron doesn't set keymaps by default anymore.
  -- You can set them here or manually add keymaps to the functions in iron.core
  keymaps = {
    send_motion = "<space>sc",
    visual_send = "<space>sc",
    send_file = "<space>sf",
    send_line = "<space>sl",
    send_mark = "<space>sm",
    mark_motion = "<space>mc",
    mark_visual = "<space>mv",
    remove_mark = "<space>md",
    cr = "<space>s<cr>",
    interrupt = "<space>s<space>",
    exit = "<space>sq",
    clear = "<space>cr",
  },
  -- If the highlight is on, you can change how it looks
  -- For the available options, check nvim_set_hl
  highlight = {
    italic = true
  },
  ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

-- require('lsp_signature').setup({
--   toggle_key = '<M-e>',
--   hint_scheme = 'Markdown',
--   fix_pos = false,
--   hint_enable = false,
--   always_trigger = false,
-- })

require("codelens_extensions").setup {
  vertical_split = false,
  rust_debug_adapter = "codelldb",
  init_rust_commands = true,
}

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' },
  })
})

require('symbols-outline').setup({
  highlight_hovered_item = true,
  show_guides = true,
  auto_preview = false,
  position = 'right',
  relative_width = false,
  width = 45,
  auto_close = false,
  show_numbers = false,
  show_relative_numbers = false,
  show_symbol_details = true,
  preview_bg_highlight = 'Normal',
  autofold_depth = nil,
  auto_unfold_hover = true,
  fold_markers = { '', '' },
  wrap = false,
  keymaps = {
    close = { "<Esc>", "q" },
    goto_location = "<Cr>",
    focus_location = "o",
    hover_symbol = "<C-space>",
    toggle_preview = "K",
    rename_symbol = "r",
    code_actions = "a",
    fold = "h",
    unfold = "l",
    fold_all = "W",
    unfold_all = "E",
    fold_reset = "R",
  },
  lsp_blacklist = {},
  symbol_blacklist = {},
  symbols = {
    File = { icon = "", hl = "@text.uri" },
    Module = { icon = "", hl = "@namespace" },
    Namespace = { icon = "", hl = "@namespace" },
    Package = { icon = "", hl = "@namespace" },
    Class = { icon = "𝓒", hl = "@type" },
    Method = { icon = "ƒ", hl = "@method" },
    Property = { icon = "", hl = "@method" },
    Field = { icon = "", hl = "@field" },
    Constructor = { icon = "", hl = "@constructor" },
    Enum = { icon = "ℰ", hl = "@type" },
    Interface = { icon = "ﰮ", hl = "@type" },
    Function = { icon = "", hl = "@function" },
    Variable = { icon = "", hl = "@constant" },
    Constant = { icon = "", hl = "@constant" },
    String = { icon = "𝓐", hl = "@string" },
    Number = { icon = "#", hl = "@number" },
    Boolean = { icon = "⊨", hl = "@boolean" },
    Array = { icon = "", hl = "@constant" },
    Object = { icon = "⦿", hl = "@type" },
    Key = { icon = "🔐", hl = "@type" },
    Null = { icon = "NULL", hl = "@type" },
    EnumMember = { icon = "", hl = "@field" },
    Struct = { icon = "𝓢", hl = "@type" },
    Event = { icon = "🗲", hl = "@type" },
    Operator = { icon = "+", hl = "@operator" },
    TypeParameter = { icon = "𝙏", hl = "@parameter" },
    Component = { icon = "", hl = "@function" },
    Fragment = { icon = "", hl = "@constant" },
  },
})

require('delaytrain').setup()

require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = require('lualine_theme').theme(),
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'filetype' },
    lualine_y = { 'location' },
    lualine_z = { clock }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

require('nvim-autopairs').setup({
  check_ts = true,
})

require('todo-comments').setup({
  signs = true,      -- show icons in the signs column
  sign_priority = 8, -- sign priority
  keywords = {
    FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  },
  gui_style = {
    fg = "NONE",         -- The gui style to use for the fg highlight group.
    bg = "BOLD",         -- The gui style to use for the bg highlight group.
  },
  merge_keywords = true, -- when true, custom keywords will be merged with the defaults
  -- highlighting of the line containing the todo comment
  -- * before: highlights before the keyword (typically comment characters)
  -- * keyword: highlights of the keyword
  -- * after: highlights after the keyword (todo text)
  highlight = {
    multiline = true,                -- enable multine todo comments
    multiline_pattern = "^.",        -- lua pattern to match the next multiline from the start of the matched keyword
    multiline_context = 10,          -- extra lines that will be re-evaluated when changing a line
    before = "",                     -- "fg" or "bg" or empty
    keyword = "wide",                -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
    after = "fg",                    -- "fg" or "bg" or empty
    pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
    comments_only = true,            -- uses treesitter to match keywords in comments only
    max_line_len = 400,              -- ignore lines longer than this
    exclude = {},                    -- list of file types to exclude highlighting
  },
  -- list of named colors where we try to extract the guifg from the
  -- list of highlight groups or use the hex color if hl not found as a fallback
  colors = {
    error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
    warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
    info = { "DiagnosticInfo", "#2563EB" },
    hint = { "DiagnosticHint", "#10B981" },
    default = { "Identifier", "#7C3AED" },
    test = { "Identifier", "#FF00FF" }
  },
  search = {
    command = "rp",
    args = {
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
    },
    pattern = [[\b(KEYWORDS):]], -- ripgrep regex
  },
})

require("zen-mode").setup({
  window = {
    backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
    -- height and width can be:
    -- * an absolute number of cells when > 1
    -- * a percentage of the width / height of the editor when <= 1
    -- * a function that returns the width or the height
    width = 120, -- width of the Zen window
    height = 1,  -- height of the Zen window
    -- by default, no options are changed for the Zen window
    -- uncomment any of the options below, or add other vim.wo options you want to apply
    options = {
      -- signcolumn = "no", -- disable signcolumn
      -- number = false, -- disable number column
      -- relativenumber = false, -- disable relative numbers
      -- cursorline = false, -- disable cursorline
      -- cursorcolumn = false, -- disable cursor column
      -- foldcolumn = "0", -- disable fold column
      -- list = false, -- disable whitespace characters
    },
  },
  plugins = {
    -- disable some global vim options (vim.o...)
    -- comment the lines to not apply the options
    options = {
      enabled = true,
      ruler = false,                -- disables the ruler text in the cmd line area
      showcmd = false,              -- disables the command in the last line of the screen
    },
    twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
    gitsigns = { enabled = false }, -- disables git signs
  },
  -- callback where you can add custom code when the Zen window opens
  on_open = function()
  end,
  -- callback where you can add custom code when the Zen window closes
  on_close = function()
  end,
})

require('twilight').setup({
  dimming = {
    alpha = 0.25, -- amount of dimming
    -- we try to get the foreground from the highlight groups or fallback color
    color = { "Normal", "#ffffff" },
    term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
    inactive = true,     -- when true, other windows will be fully dimmed (unless they contain the same buffer)
  },
  context = 10,          -- amount of lines we will try to show around the current line
  treesitter = true,     -- use treesitter when available for the filetype
  -- treesitter is used to automatically expand the visible text,
  -- but you can further control the types of nodes that should always be fully expanded
  expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
    "function",
    "method",
    "table",
    "if_statement",
  },
  exclude = {}, -- exclude these filetypes
})

require('gitsigns').setup {
  signs                        = {
    add          = { hl = 'Identifier', text = '│' },
    change       = { hl = 'Special', text = '│' },
    delete       = { hl = 'Type', text = '_' },
    topdelete    = { hl = 'Constant', text = '‾' },
    changedelete = { hl = 'PreProc', text = '~' },
    untracked    = { hl = 'Underlined', text = '┆' },
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
  yadm                         = {
    enable = false
  },
}

local exs_template = [[
defmodule {camelcase|capitalize|dot} do

end]]

local test_template = [[
defmodule {camelcase|capitalize|dot}Test do
  use ExUnit.Case, async: true
  alias {camelcase|capitalize|dot}, as: Subject
  doctest Subject
end]]

vim.g.projectionist_heuristics = {
  -- Elixir
  ['mix.exs'] = {
    ['apps/*/mix.exs'] = { type = 'app' },
    ['lib/*.ex'] = {
      type = 'lib',
      alternate = 'test/{}_test.exs',
      template = exs_template,
    },
    ['test/*_test.exs'] = {
      type = 'test',
      alternate = 'lib/{}.ex',
      template = test_template,
    },
    ['mix.exs'] = { type = 'mix' },
    ['config/*.exs'] = { type = 'config' },
  },
  -- CPP
  ['compile_flags.txt'] = {
    ['src/*.cpp'] = {
      type = 'source',
      alternate = 'src/{}.hpp',
      template = [[#include "{}.hpp"]],
    },
    ['src/*.hpp'] = {
      type = 'header',
      alternate = 'src/{}.cpp',
      -- TODO: ifndef def endif
    },
    ['makefile'] = { type = 'makefile' },
  }
}
