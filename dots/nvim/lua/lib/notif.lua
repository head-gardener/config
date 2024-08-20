local M = {}

function M.notif(text)
  local notify = require('notify')
  notify(vim.inspect(text))
end

setmetatable(M, {
  __call = function(_, ...)
    M.notif(...)
  end
})

return M
