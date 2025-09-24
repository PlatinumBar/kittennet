---originally called droneid :p

local m = {}

local COMPARRAYSIZE = 'c3'
---@type string[]
---list of every single component there is and that may mattter to drones at all :krzysztof:
m.components = {
  ['debug'] = 1,
  ['crafting'] = 2,
  ['data'] = 3,
  ['tablet'] = 4,
  ['filesystem'] = 5,
  ['drive'] = 6,
  ['experience'] = 7,
  ['geolyzer'] = 8,
  ['internet'] = 9,
  ['inventory_controller'] = 10,
  ['leash'] = 11,
  ['microcontroller'] = 12,
  ['motion_sensor'] = 13,
  ['navigation'] = 14,
  ['piston'] = 15,
  ['redstone'] = 16,
  ['transposer'] = 17,
  ['tractor_beam'] = 18,
  ['tank_controller'] = 19,
  ['robot'] = 20,
  ['modem'] = 21,
}
m.components2 = {
  'debug',
  'crafting',
  'data',
  'tablet',
  'filesystem',
  'drive',
  'experience',
  'geolyzer',
  'internet',
  'inventory_controller',
  'leash',
  'microcontroller',
  'motion_sensor',
  'navigation',
  'piston',
  'redstone',
  'transposer',
  'tractor_beam',
  'tank_controller',
  'robot',
  'modem',
}

---@param sets table<number,boolean>
---@return string
function m:t2b(sets)
  local max_index = 0
  for i in pairs(sets) do
    if i > max_index then max_index = i end
  end
  local byte_count = math.floor(max_index / 8) + 1
  local bytes = {}
  for i = 1, byte_count do
    bytes[i] = 0
  end
  for i, state in pairs(sets) do
    if state then
      local byte_index = math.floor(i / 8) + 1
      local bit_index = i % 8
      bytes[byte_index] = bytes[byte_index] | (1 << bit_index)
    end
  end
  local out = {}
  for i = 1, byte_count do
    out[i] = string.char(bytes[i])
  end
  return table.concat(out)
end
---@param bytearr string
---@param offset number
function m:getbit(bytearr, offset)
  local byte_index = math.floor(offset / 8) + 1
  local bit_index = offset % 8
  local b = string.byte(bytearr, byte_index)
  return (b & (1 << bit_index)) ~= 0
end
---@param id string
---@param mask string
function m:filter(id, mask)
  local masklen = #mask
  for i = 1, masklen do
    local a = string.byte(id, i)
    local b = string.byte(mask, i)
    if (a & b) ~= b then return false end
  end
  return true
end

---@param u string # uuid
---@return string #byte array
---produces 16 bytes
function m.u2b(u)
  t = {}
  for p in u:gmatch('[^%-]+') do
    t[#t + 1] = tonumber(p, 16)
  end
  return string.pack('I4HHHI6', table.unpack(t))
end
---@param b string # byte array
---@param o? integer #offset
function m.b2u(b, o) return string.format('%02x-%02x-%02x-%02x-%012x', string.unpack('I4HHHI6', b, o or 1)) end

function m:bytes2table(str)
  local t = {}
  for byte_index = 1, #str do
    local b = string.byte(str, byte_index)
    for bit_index = 0, 7 do
      local mask = 1 << bit_index
      local global_index = (byte_index - 1) * 8 + bit_index
      t[global_index] = (b & mask) ~= 0
    end
  end
  return t
end

function m:bytes2components(str)
  local t = {}
  local insert = table.insert
  for byte_index = 1, #str do
    local b = string.byte(str, byte_index)
    for bit_index = 0, 7 do
      local mask = 1 << bit_index
      local global_index = (byte_index - 1) * 8 + bit_index
      if (b & mask) ~= 0 then insert(t, self.components2[global_index]) end
    end
  end
  return t
end
---@return string
function m:genSelfID()
  local comps = {}
  local out = {}
  for k, v in pairs(component.list()) do
    if self.components[v] then comps[self.components[v]] = true end
  end
  out[1] = self:t2b(comps)
  out[2] = self.u2b(computer.address())
  local modem = _G.cmp_lookup('modem')
  ---@cast modem modem
  local modem_addr = (modem and modem.address) or self.b2u('\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00')
  out[3] = self.u2b(modem_addr)
  return table.concat(out, '')
end
---@param id string
function m:id2table(id)
  local out = {}
  local unpack = string.unpack
  local v, off = unpack(COMPARRAYSIZE, id, 1)
  out.compArray = v
  out.components = self:bytes2components(out.compArray)
  out.computer_id, off = self.b2u(unpack('c16', id, off))
  out.modem_id, off = self.b2u(unpack('c16', id, off))
  return out
end

m.selfid = m:genSelfID()

return m
