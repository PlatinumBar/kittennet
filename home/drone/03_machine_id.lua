---originally called droneid :p

local m = {}
---@type string[]
---list of every single component there is and that may mattter to drones at all :krzysztof:
m.components = {
  'modem',
  'debug',
  'crafting',
  'data',
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
}

function m:genSelfID()
  for k, v in pairs(component.list()) do
  end
end

function bit_set(str, offset, bool)
  local bytes = #str

  local o_byte, o_bit = math.floor(offset / 8) + 1, offset % 8
end

---@param u string # uuid
---@return string #byte array
---produces 16 bytes
function u2b(u)
  t = {}
  for p in u:gmatch('[^%-]+') do
    t[#t + 1] = tonumber(p, 16)
  end
  return string.pack('I4HHHI6', table.unpack(t))
end
---@param b string # byte array
---@param o integer #offset
function b2u(b, o) return string.format('%02x-%02x-%02x-%02x-%012x', string.unpack('I4HHHI6', b, o or 0)) end

m.self = m:genSelfID()

if _G.self.type == 'drone' then
  if _G.say ~= nil then _G.say('loaded the ./droneid.lua module (_G.modules.id)') end
  _G.modules['id'] = m
else
  return m
end
