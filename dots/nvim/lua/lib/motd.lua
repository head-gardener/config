local M = {}

function M.get_plugins()
  return require('lazy').plugins()
end

function M.get_mapoftheday_raw(plugins)
  local keys = nil

  repeat
    keys = plugins[math.random(1, #plugins)].keys
  until keys

  if type(keys) == 'function' then keys = keys() end
  return keys[math.random(1, #keys)]
end

local function prettify_key(key)
  local res = key[1]
  if type(key[2]) == 'function' then
    res = res .. ' (function)'
  else
    res = res .. ' (' .. key[2] .. ')'
  end
  if key.desc then res = res .. ': ' .. key.desc end
  return res
end

function M.get_mapoftheday()
  return prettify_key(M.get_mapoftheday_raw(M.get_plugins()))
end

return M
