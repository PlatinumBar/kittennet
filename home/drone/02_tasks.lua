---@type table<number,task>
_G.tasks = {}
_G.taskid = 10
---@param f thread
---@param type ?string
---@param prio ?number
---@param static ?boolean
function newtask(f, type, prio, static) return { s = static or false, f = f, t = type or 'fn', p = prio or 0 } end
---@return task|nil
function takeHighestPrio()
  local hv = 0
  local id = -1
  if #tasks == 0 then return nil end
  for i, v in ipairs(tasks) do
    if v.p > hv then id = i end
  end
  t = tasks[id]
  if not t.s then tasks[id].p = t.p - 1 end
  return t
end

tasks[100] = newtask(
  coroutine.create(function()
    while true do
      local info = table.pack(computer.pullSignal(pullInterval)) -- this is a bad idea but i think it saves energy
      if info[1] and info ~= nil then
        if signal_callbacks[info[1]] ~= nil then
          local c = coroutine.create(function()
            local ok, err = pcall(signal_callbacks[info[1]], info)
            if not ok then
              say('error: ' .. tostring(err))
              computer.pushSignal('exception', 'main loop')
            end
          end)
          coroutine.resume(c)
          if coroutine.status(c) ~= 'dead' then
            taskid = taskid + 1
            tasks[taskid] = newtask(c, info[1], 1 --[[should have a higher priority so that its called before the new task creation i guess]], false)
          end
          coroutine.yield(true)
        end
      else
        -- do other tasks here i guess
        coroutine.yield(false) -- pretend like the pull didnt happen :C
      end
    end
  end),
  'sigpull'
)
tasks[999] = newtask(
  coroutine.create(function()
    while true do
      clock = computer.uptime()
      coroutine.yield()
    end
  end),
  'clock',
  -1
)

function execution_handle()
  for k, v in pairs(tasks) do
    local success, res = coroutine.resume(v.f, k)
    if success and not v.s then v.p = v.p - 1 end
    if not success then
      computer.pushSignal('exception', 'tasks_exec', res)
      tasks[k] = nil
    else
      if res then break end -- convention: if a task yields true it means that a tick operation has been consumed -> you should break. this means that the pullsignal task is often going to stop the clock updates but oh well
    end
  end
end
_G.mainfunc = execution_handle()
