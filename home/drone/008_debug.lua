function t2s(t, indent)
  indent = indent or 0
  local lines = {}
  local pad = string.rep('  ', indent)
  table.insert(lines, '{')
  for k, v in pairs(t) do
    local key = tostring(k)
    if type(k) == 'number' then
      key = '[' .. tostring(k) .. ']'
    elseif type(k) == 'table' then
      key = '"' .. t2s(key) .. '"'
    end
    local value
    if type(v) == 'table' then
      value = t2s(v, indent + 1)
    elseif type(v) == 'string' then
      value = string.format('%q', v)
    else
      value = tostring(v)
    end
    table.insert(lines, pad .. '  ' .. key .. ' = ' .. value .. ',')
  end
  table.insert(lines, pad .. '}')
  return table.concat(lines, '\n')
end

say(string.format('used/total/left: {(%d)(%d)(%d)}', computer.totalMemory() - computer.freeMemory(), computer.totalMemory(), computer.freeMemory()))

local t = require('004_tasks')
tasks[1] = t.newtask(
  coroutine.create(function()
    while true do
      local info = table.pack(computer.pullSignal(pullInterval)) -- this is a bad idea but i think it saves energy
      if info[1] and info ~= nil then
        pullInterval = 0.01
        if signal_callbacks[info[1]] ~= nil then
          local c = coroutine.create(function()
            local ok, err = pcall(signal_callbacks[info[1]], info)
            if not ok then
              say('error: ' .. tostring(err))
              computer.pushSignal('exception', 'main loop')
            end
          end)
          coroutine.resume(c)
          -- if coroutine.status(c) ~= 'dead' then
          --   taskid = taskid + 1
          --   tasks[taskid] = newtask(c, info[1], 1 --[[should have a higher priority so that its called before the new task creation i guess]], false)
          -- end
          coroutine.yield(true)
        else
          say('missing callback for ' .. tostring(info[1]))
        end
      else
        pullInterval = 5
        -- do other tasks here i guess
        coroutine.yield(false) -- pretend like the pull didnt happen :C
      end
    end
  end),
  'sigpull',
  0,
  0
)
t.newtask1(coroutine.create(function()
  while true do
    say(string.format('clock:%s', clock))

    coroutine.yield()
  end
end))
function execution_handle()
  for k, v in ipairs(tasks) do
    if v.prio <= 0 then
      v.prio = v.default
      local success, res = coroutine.resume(v.func, k)
      if not success then
        computer.pushSignal('exception', 'tasks_exec', res)
        tasks[k] = nil
      end
      if res then
        v.prio = 0
        break
      end
    else
      v.prio = v.prio - 1
    end
  end
end
_G.mainfunc = execution_handle
