function t2s(t, indent, seen)
  indent = indent or 0
  local lines = {}
  local seen1 = seen or {}
  if seen1[tostring(t)] then return 'repeated' end
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

local function announce_modules()
  for k, v in pairs(component.list()) do
    say(string.format('mod %s -> %s', k, v))
  end
end

say('var4')
announce_modules()

say('var2')
fsay = function(str, ...)
  local varargs = table.pack(...)
  say(string.format(str, table.unpack(varargs)))
end

say('var1')

local vec = require('003_veclib')
local nav = component.proxy(component.list('navigation')())
local polaris = require('008_polaris')

say('going to the nearest waypoint')
---@type { vec:vec3,redstone:number,address:string ,label:string}
local closest = { vec = vec.new(0, 0, 300000000), label = 'default' }
local ran = false
local all_wp = vec.nodes_to_vec(nav.findWaypoints(100000))

say('var3')
---@cast nav navigation
for label, point in pairs(all_wp) do
  if point.vec:dist(vec.ORIGIN) < closest.vec:dist(vec.ORIGIN) then
    closest = point
    ran = true
  end
end

-- if ran then
--   fsay('moving to %s (label:%s)', t2s(closest), closest.label)
--   polaris:move_relative_vec(closest.vec + vec.new(0, 1, 0))
-- end
if all_wp['charger'] then polaris:move_relative_vec(all_wp['charger'].vec + vec.new(0, 1, 0)) end
return nil
