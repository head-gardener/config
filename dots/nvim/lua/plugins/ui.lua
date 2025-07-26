return {
  {
    'smjonas/live-command.nvim',
    lazy = false,
    config = {
      commands = {
        Norm = { cmd = "norm" },
        G = { cmd = "global" },
        D = { cmd = "delete" },
      },
    },
  },
  {
    'Bekaboo/dropbar.nvim',
    enabled = true,
    config = {
      bar = {
        enable = true,
      },
    },
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    lazy = false,
    config = false,
    init = function ()
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = 'rainbow-delimiters.strategy.global',
          vim = 'rainbow-delimiters.strategy.local',
        },
        query = {
          [''] = 'rainbow-delimiters',
        },
        priority = {
          [''] = 110,
        },
        highlight = {
          'RainbowDelimiterViolet',
          'RainbowDelimiterYellow',
          'RainbowDelimiterRed',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterCyan',
          'RainbowDelimiterBlue',
        },
      }
    end
  },
  {
    'xiyaowong/transparent.nvim',
    lazy = false,
  },
  {
    'stevearc/oil.nvim',
    config = function()
      local is_detailed = false
      local short_columns = { "icon", }
      local long_columns = { "icon", "permissions", "size", "mtime", }

      local function parse_output(proc)
        local result = proc:wait()
        local ret = {}
        if result.code == 0 then
          for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            line = line:gsub("/$", "")
            ret[line] = true
          end
        end
        return ret
      end

      local function new_git_status()
        return setmetatable({}, {
          __index = function(self, key)
            local ignore_proc = vim.system(
            { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
            {
              cwd = key,
              text = true,
            }
            )
            local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
              cwd = key,
              text = true,
            })
            local ret = {
              ignored = parse_output(ignore_proc),
              tracked = parse_output(tracked_proc),
            }

            rawset(self, key, ret)
            return ret
          end,
        })
      end
      local git_status = new_git_status()

      local refresh = require("oil.actions").refresh
      local orig_refresh = refresh.callback
      refresh.callback = function(...)
        git_status = new_git_status()
        orig_refresh(...)
      end

      require("oil").setup {
        default_file_explorer = true,
        columns = short_columns,
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = "nvic",
        },
        delete_to_trash = false,
        skip_confirm_for_simple_edits = false,
        prompt_save_on_select_new_entry = true,
        cleanup_delay_ms = 2000,
        lsp_file_methods = {
          enabled = true,
          timeout_ms = 1000,
          autosave_changes = false,
        },
        constrain_cursor = "editable",
        watch_for_changes = true,
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-j>"] = "actions.select",
          ["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
          ["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
          ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
          ["<C-e>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["<C-i>"] = {
            callback = function()
              if is_detailed then
                require('oil').set_columns(short_columns)
              else
                require('oil').set_columns(long_columns)
              end
              is_detailed = not is_detailed
            end,
            desc = "Toggle column number"
          },
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory", mode = "n" },
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        },
        use_default_keymaps = true,
        view_options = {
          show_hidden = false,
          is_hidden_file = function(name, bufnr)
            local dir = require("oil").get_current_dir(bufnr)
            local is_dotfile = vim.startswith(name, ".") and name ~= ".."
            if not dir then
              return is_dotfile
            end
            if is_dotfile then
              return not git_status[dir].tracked[name]
            else
              return git_status[dir].ignored[name]
            end
          end,
          is_always_hidden = function(_, _)
            return false
          end,
          natural_order = true,
          case_insensitive = true,
        },
        float = {
          -- Padding around the floating window
          padding = 2,
          max_width = 0,
          max_height = 0,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          get_win_title = function() return " oil up " end,
          preview_split = "auto",
          override = function(conf)
            return conf
          end,
        },
        preview = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = 0.9,
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          update_on_cursor_moved = true,
        },
        progress = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = { 10, 0.9 },
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          minimized_border = "none",
          win_options = {
            winblend = 0,
          },
        },
        ssh = {
          border = "rounded",
        },
        keymaps_help = {
          border = "rounded",
        },
      }
    end,
    keys = {
      { "<Leader>fm", ":Oil --float<CR>", desc = "Open file manager" },
    },
    lazy = false,
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
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
    init = function()
      local notify = require 'notify'

      vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local lvl = ({
          'ERROR',
          'WARN',
          'INFO',
          'DEBUG',
        })[result.type]
        notify({ result.message }, lvl, {
          title = 'LSP | ' .. client.name,
          timeout = 10000,
          keep = function()
            return lvl == 'ERROR' or lvl == 'WARN'
          end,
        })
      end

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
      vim.cmd [[highlight link NotifyERRORBody Normal]]
      vim.cmd [[highlight link NotifyWARNBody Normal]]
      vim.cmd [[highlight link NotifyINFOBody Normal]]
      vim.cmd [[highlight link NotifyDEBUGBody Normal]]
      vim.cmd [[highlight link NotifyTRACEBody Normal]]
    end,
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
    'folke/zen-mode.nvim',
    opts = {
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
          -- signcolumn = 'no', -- disable signcolumn
          -- number = false, -- disable number column
          -- relativenumber = false, -- disable relative numbers
          -- cursorline = false, -- disable cursorline
          -- cursorcolumn = false, -- disable cursor column
          -- foldcolumn = '0', -- disable fold column
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
    },
    keys = function()
      return {
        { '<Space>ze', ':ZenMode<CR>', noremap = true },
      }
    end,
  },
  {
    'folke/twilight.nvim',
    opts = {
      dimming = {
        alpha = 0.25, -- amount of dimming
        -- we try to get the foreground from the highlight groups or fallback color
        color = { 'Normal', '#ffffff' },
        term_bg = '#000000', -- if guibg=NONE, this will be used to calculate text color
        inactive = true,     -- when true, other windows will be fully dimmed (unless they contain the same buffer)
      },
      context = 10,          -- amount of lines we will try to show around the current line
      treesitter = true,     -- use treesitter when available for the filetype
      -- treesitter is used to automatically expand the visible text,
      -- but you can further control the types of nodes that should always be fully expanded
      expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
        'function',
        'method',
        'table',
        'if_statement',
      },
      exclude = {}, -- exclude these filetypes
    },
    keys = function()
      return {
        { '<Space>tw', ':Twilight<CR>', noremap = true },
      }
    end,
  },
  {
    'folke/todo-comments.nvim',
    opts = {
      signs = true,      -- show icons in the signs column
      sign_priority = 8, -- sign priority
      keywords = {
        FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
        TODO = { icon = ' ', color = 'info' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
      gui_style = {
        fg = 'NONE',         -- The gui style to use for the fg highlight group.
        bg = 'BOLD',         -- The gui style to use for the bg highlight group.
      },
      merge_keywords = true, -- when true, custom keywords will be merged with the defaults
      -- highlighting of the line containing the todo comment
      -- * before: highlights before the keyword (typically comment characters)
      -- * keyword: highlights of the keyword
      -- * after: highlights after the keyword (todo text)
      highlight = {
        multiline = true,                -- enable multine todo comments
        multiline_pattern = '^.',        -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10,          -- extra lines that will be re-evaluated when changing a line
        before = '',                     -- 'fg' or 'bg' or empty
        keyword = 'wide',                -- 'fg', 'bg', 'wide', 'wide_bg', 'wide_fg' or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = 'fg',                    -- 'fg' or 'bg' or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        comments_only = true,            -- uses treesitter to match keywords in comments only
        max_line_len = 400,              -- ignore lines longer than this
        exclude = {},                    -- list of file types to exclude highlighting
      },
      -- list of named colors where we try to extract the guifg from the
      -- list of highlight groups or use the hex color if hl not found as a fallback
      colors = {
        error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
        warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
        info = { 'DiagnosticInfo', '#2563EB' },
        hint = { 'DiagnosticHint', '#10B981' },
        default = { 'Identifier', '#7C3AED' },
        test = { 'Identifier', '#FF00FF' }
      },
      search = {
        command = 'rp',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      },
    },
  },
  {
    'enddeadroyal/symbols-outline.nvim',
    opts = {
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
        close = { '<Esc>', 'q' },
        goto_location = '<Cr>',
        focus_location = 'o',
        hover_symbol = '<C-space>',
        toggle_preview = 'K',
        rename_symbol = 'r',
        code_actions = 'a',
        fold = 'h',
        unfold = 'l',
        fold_all = 'W',
        unfold_all = 'E',
        fold_reset = 'R',
      },
      lsp_blacklist = {},
      symbol_blacklist = {},
      symbols = {
        File = { icon = '', hl = '@text.uri' },
        Module = { icon = '', hl = '@namespace' },
        Namespace = { icon = '', hl = '@namespace' },
        Package = { icon = '', hl = '@namespace' },
        Class = { icon = '𝓒', hl = '@type' },
        Method = { icon = 'ƒ', hl = '@method' },
        Property = { icon = '', hl = '@method' },
        Field = { icon = '', hl = '@field' },
        Constructor = { icon = '', hl = '@constructor' },
        Enum = { icon = 'ℰ', hl = '@type' },
        Interface = { icon = 'ﰮ', hl = '@type' },
        Function = { icon = '', hl = '@function' },
        Variable = { icon = '', hl = '@constant' },
        Constant = { icon = '', hl = '@constant' },
        String = { icon = '𝓐', hl = '@string' },
        Number = { icon = '#', hl = '@number' },
        Boolean = { icon = '⊨', hl = '@boolean' },
        Array = { icon = '', hl = '@constant' },
        Object = { icon = '⦿', hl = '@type' },
        Key = { icon = '🔐', hl = '@type' },
        Null = { icon = 'NULL', hl = '@type' },
        EnumMember = { icon = '', hl = '@field' },
        Struct = { icon = '𝓢', hl = '@type' },
        Event = { icon = '🗲', hl = '@type' },
        Operator = { icon = '+', hl = '@operator' },
        TypeParameter = { icon = '𝙏', hl = '@parameter' },
        Component = { icon = '', hl = '@function' },
        Fragment = { icon = '', hl = '@constant' },
      },
    },
    keys = function()
      return {
        { '<Leader>sd', ':SymbolsOutline<CR>', noremap = true },
      }
    end,
  },
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
