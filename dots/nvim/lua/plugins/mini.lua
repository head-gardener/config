return {
  {
    'echasnovski/mini.nvim',
    config = function()
      local function setup(module, args)
        local mod = require(module)
        mod.setup(args(mod))
      end

      setup('mini.ai', function()
        return {}
      end)

      -- ga
      setup('mini.align', function()
        return {}
      end)

      setup('mini.starter', function()
        return {
          footer = '',
        }
      end)

      setup('mini.indentscope', function(mod)
        return {
          draw = {
            delay = 200,
            animation = mod.gen_animation.linear({
              easing = 'out',
              duration = 10,
            })
          },
          symbol = '░',
        }
      end)

      require('mini.cursorword').setup({})
      require('mini.trailspace').setup({})
    end,
  },
}
