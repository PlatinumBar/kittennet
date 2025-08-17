local m = {}
---@diagnostic disable:unused-local,unused-function
--#region remove
---@type modem
---@class modem
m.modem = _G.modem
--#endregion remove
m.req_port = _G.REQ_PORT or 1236
m.resp_port = _G.RESP_PORT or 1235

--this entire thing can be replaced with constants if the ram/eepyrom gets too tight
m.types = {
  'SYN', --the 3 way TCP handshake types, nothing special
  'ACK+SYN',
  'ACK',
  'CRIR', --cortex info request [ SEED:int, SILENT:bool, INFO:string ] -ex CRIR,1,true,world.23.21
  'CRIS', --cortex info response [ SEED:int, CRIS_STAT, ?info:??? ]
  CRIS_STAT = {
    NI = 1, --no info
    IAS = 2, --info available (?info:string)
    IAT = 3, --table (packed)
    IAN = 4, --number (lua_number)
    IAF = 5, --info available (?info:function (info=pcall(func)) )
    IAR = 6, --info available + reader function src
  },
}
---list of { random number seed: { removal timestamp, coroutine } }
m.queue = {}

---@param data string
---@param allow_silent boolean
---@param addr string|nil
---@param thread_timeout number|nil
---@async
---allow_silent should be true most of the times unless you are like ultra stupid or something
function m:CRIR_start(data, allow_silent, addr, thread_timeout)
  local seed = math.random(0, 0xffffffff)
  local self_proc = coroutine.running()
  if addr then
    self.modem.send(addr, m.req_port, m.types[4], string.pack('BLz', allow_silent and 1 or 0, seed, data))
  else
    self.modem.broadcast(m.req_port, m.types[4], string.pack('BLz', allow_silent and 1 or 0, seed, data))
  end
  self.queue[seed] = {
    timeout = (thread_timeout or 1.5) + computer.uptime(),--[[timeout in seconds + computer.uptime ~~ removal timestamp]]
    proc = self_proc,
  }

  return coroutine.yield()
end

---@param time number
function m:remove_timed_out(time)
  local now = time or computer.uptime()
  for seed, val in pairs(self.queue) do
    if val.timeout <= now then
      coroutine.resume(val.proc, nil)
      self.queue[seed] = nil
    end
  end
end

function m:CRIR_response(remote_addr, port, distance, stringinfo)
  if port ~= self.req_port then
    return --probably not for us i guess?
  end

  ---@type number,number,string
  local allow_silent_b, seed, data = string.unpack('BLz', stringinfo)

  local function send_no_info()
    if allow_silent_b == 0 then self.modem.send(remote_addr, self.resp_port, string.pack('B', m.types.CRIS_STAT.NI)) end
  end

  local f, err = load('return ' .. data)
  if not f then
    send_no_info()
    return
  end
  ---@cast f function
  local finished, result = pcall(f)
  if not finished then
    send_no_info()
    return
  end
end

m.net = { __index = function(_, name) return m:req_start(name, true) end }

m.modem.open(m.req_port)
m.modem.open(m.resp_port)
return m
