local m = {}
--#region remove
---@type modem
---@class modem
m.modem = _G.modem
--#endregion remove
m.req_port = _G.REQ_PORT or 1236
m.resp_port = _G.RESP_PORT or 1235

m.types = {
  'SYN', --the 3 way TCP handshake types, nothing special
  'ACK+SYN',
  'ACK',
  'CRIR', --cortex info request [ SEED:int, SILENT:bool, INFO:string ] -ex CRIR,1,true,world.23.21
  'CRIS', --cortex info response [ SEED:int, CRIS_STAT, VERSION:number ?info:??? ]
  ---the version is here to control which nodes contain outdated info
  ---if the CRIS_STAT
  CRIS_STAT = {
    'NI', --no info
    'IAS', --info available (?info:string)
    'IAF', --info available (?info:function (info=pcall(func)) )
    'IAR', --info available + reader function src
  },
}
---list of { random number seed, removal timestamp }
---@type table<integer,table<number,thread>>
m.queue = {}

---@alias data string
---@alias allow_silent boolean
---@alias addr string
---@alias timeout number
---@async
---allow_silent should be true most of the times unless you are like ultra stupid or something
function m:req_start(data, allow_silent, addr, timeout)
  local seed = math.random(0, 0xffffffff)
  local self_proc = coroutine.running()
  if addr then
    self.modem.send(addr, m.req_port, m.types[4], string.pack('BLz', allow_silent and 1 or 0, seed, data))
  else
    self.modem.broadcast(m.req_port, m.types[4], string.pack('BLz', allow_silent and 1 or 0, seed, data))
  end
  self.queue[seed] = {
    (timeout or 1) + computer.uptime(),--[[timeout in seconds + computer.uptime ~~ removal timestamp]]
    self_proc,
  }

  return coroutine.yield()
end

---@param time number
function m:remove_timed_out(time)
  local now = time or computer.uptime()
  for seed, val in pairs(self.queue) do
    if val[1] <= now then
      coroutine.resume(val[2], nil)
      self.queue[seed] = nil
    end
  end
end

function CRIR_response()
  
end

m.net = { __index = function(_, name) return m:req_start(name, true) end }

return m
