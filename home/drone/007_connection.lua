local s = {} --network stack
---@type modem
s.modem = nil
s.seq = 1
---@type table<number,table<string,session>>
s.sessions = {} -- ongoing information transfer
s.default_port = 5555
s.personal_port = math.random(1000, 65000)
---@type table<{id:string,distance:number,pos:vec3}>
s.neighbours = {}
s.serializer = require('006_bytearray')

---creates a ""process"" that just sits in the sessions table, does not create a new coroutine, just uses the one from pulltask
---@param from string
---@param ID number
---@param timeout? number
function s:makeProc(from, ID, timeout)
  if not self.sessions[ID] then self.sessions[ID] = {} end
  ---@type session
  local t = {
    thread = coroutine.running(),
    uuid = from,
    timeout = timeout or 1,
  }

  self.sessions[ID][from] = t
end

function s:closeProc(from, ID)
  if self.sessions[ID][from].closer then self.sessions[ID][from].closer(self.sessions[ID][from]) end
  self.sessions[ID][from] = nil
  if self.sessions[ID] == {} then self.sessions[ID] = nil end
end
---@param from string
---@param port number
---@param dist number
---@param data string
function s:procResumeCall(from, port, dist, data)
  --this nullrefs and shits the operation btw
  coroutine.resume(self.sessions[port][from].thread, data, dist)
end

---@type table<string, fun(from:string,port:number,distance:number,data:string)>
local incoming_handlers = {
  ['rc'] = function(v1, v2, v3, v4)
    local tref = s
    tref:procResumeCall(v1, v2, v3, v4)
  end,
}

return s
