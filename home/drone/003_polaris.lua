---@class vec3
---@field x number
---@field y number
---@field z number
---
local vec3 = {}
vec3.__index = vec3
function vec3:dist(p2)
  local dx = self.x - p2.x
  local dy = self.y - p2.y
  local dz = self.z - p2.z
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end
---@param x? number
---@param y? number
---@param z? number
---@return vec3
function vec3.new(x, y, z) return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, vec3) end

_G.coords = vec3.new() -- 0 0, reset later
---@return string # byte array
function vec3:serialize()
  if self.x < (256 ^ 2) and self.y < (256 ^ 2) and self.z < (256 ^ 2) then
    return string.pack('BHHH', 0, self.x, self.y, self.z)
  else
    return string.pack('BIII', 1, self.x, self.y, self.z)
  end
end
function vec3.deserialize(inp)
  local unp = string.unpack
  if unp('B', inp, 1) ~= 0 then
    return unp('III', inp, 2)
  else
    return unp('HHH', inp, 2)
  end
end
return vec3
