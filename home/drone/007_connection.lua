local s = {} --network stack
---@type modem
s.modem = nil
s.seq = 1
---@type table<number,table<string,session>>
s.sessions = {} -- ongoing information transfer
s.default_port = 5555
s.personal_port = math.random(1000, 65000)
s.modem.open(s.personal_port)
---@type table<{id:string,distance:number,pos:vec3}>
s.neighbours = {}
s.serializer = require('drone.006_bytearray')

---@param target string # UUID
---@param port number
---meant to run when a new node appears, to add it as a neighbour
---handshake is A  -> ACK ->  B
---             A  <- SYNACK <- B
---             A -> MID1 -> B
---             A <- MID2 <- B
---             A -> MID2+SYNACKeq -> B
---             A <- (opt) fail? <- B
function s:handshake(target, port)
  self.seq = self.seq + 1
  self:makeProc(target, port)
  local selfid = require('drone.005_machine_id').selfid
  self.modem.send(target, port, self.serializer.serialize({ seq = self.seq, selfid = selfid }))
  local resp,dist = coroutine.yield()


  --   self.modem.send(target, port, 'hs', tostring(self.seq))
  --   --- A  -> ACK ->  B
  --   self.seq = self.seq + 1
  --   self:makeProc(target, port)
  --
  --   -- A  <- SYNACK <- B
  --   local synack, dist = coroutine.yield()
  --   -- A -> MID1 -> B
  --   self.modem.send(
  --     target,
  --     port,
  --     'rc',
  --     self.serializer.serialize({ id = require('drone.005_machine_id').selfid, pos = _G.coords, sp = self.personal_port })
  --   )
  --   -- A <- MID2 <- B
  --   local info1, dist2 = coroutine.yield()
  --   local info = self.serializer.deserialize(info1)
  --   if dist2 ~= dist then
  --     self.modem.send(target, port, 'hsfail')
  --     return
  --   end
  -- -- A -> MID2+SYNACKeq -> B
  --
  --   self.modem.send(target, port, 'rc', self.serializer.serialize({ i = info, s = synack + 1 }))
  --
  --   table.insert(self.neighbours, { id = info.id, distance = dist, pos = info.pos })
  --
  --   self:closeProc(target, port)
end

---
---@param from string
---@param port number
---@param distance number
---@param data string
function s:hs_resp(from, port, distance, data)
  -- --A  -> ACK ->  B
  --
  --   self:makeProc(from, port)
  --   --   A -> MID1 -> B
  --
  -- -- A  <- SYNACK <- B
  --   self.modem.send(from, port, 'rc', self.seq + tonumber(data))
  --   local selfInfo = { id = require('drone.005_machine_id').selfid, pos = _G.coords, sp = self.personal_port }
  -- --- A -> MID1 -> B
  --   local infoS, dist = coroutine.yield()
  --   local info = self.serializer.deserialize(infoS)
  --
  --   -- A <- MID2 <- B
  --   self.modem.send(from, port, 'rc', self.serializer.serialize(selfInfo))
  --   local fi, dist2 = coroutine.yield()
  --   local conf = self.serializer.deserialize(fi)
  --
  --
  -- ---  A <- (opt) fail? <- B
  --   table.insert(self.neighbours, { id = info.id, distance = dist, pos = info.pos })
  --   self:closeProc(from, port)
end

-- ---@param from string
-- ---@param port number
-- ---@return session
-- function s:getProc(from, port)
--
-- end

function s:makeProc(from, port)
  if not self.sessions[port] then self.sessions[port] = {} end
  ---@type session
  local t = {
    thread = coroutine.running(),
    uuid = from,
  }

  self.sessions[port][from] = t
end

function s:closeProc(from, port)
  self.sessions[port][from] = nil
  if self.sessions[port] == {} then self.sessions[port] = nil end
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
