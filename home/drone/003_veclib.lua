---@class vec3
---@field x number
---@field y number
---@field z number
---
local vec3 = {}


vec3.__index = vec3
function vec3:dist(p2)
  local abs = math.abs
  local dx = abs(self.x - p2.x)
  local dy = abs(self.y - p2.y)
  local dz = abs(self.z - p2.z)
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end
---@param x? number
---@param y? number
---@param z? number
---@return vec3
function vec3.new(x, y, z) return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, vec3) end

---@return string # byte array
function vec3:serialize()
  if self.x < (256 ^ 2) and self.y < 256 and self.z < (256 ^ 2) then
    return string.pack('BHBH', 0, self.x, self.y, self.z)
  else
    return string.pack('BIII', 1, self.x, self.y, self.z)
  end
end
---@param a vec3
---@param b vec3
function vec3.__add(a, b) return vec3.new(a.x + b.x, a.y + b.y, a.z + b.z) end
function vec3.__sub(a, b) return vec3.new(a.x - b.x, a.y - b.y, a.z - b.z) end
function vec3.deserialize(inp)
  local unp = string.unpack
  if unp('B', inp, 1) ~= 0 then
    return vec3.new(unp('III', inp, 2))
  else
    return vec3.new(unp('HBH', inp, 2))
  end
end
---@param a vec3
---@param b vec3
function vec3.__eq(a, b) return rawequal(a.x, b.x) and rawequal(a.y, b.y) and rawequal(a.z, b.z) end
function vec3:is_vector() return getmetatable(self) == vec3.__index end

---@param a vec3
---@param b vec3|number
function vec3.__mul(a, b)
  if
    vec3.is_vector(b --[[ @as vec3 ]])
  then
    return vec3.new(a.x * b.x, a.y * b.y, a.z * b.z)
  else
    return vec3.new(a.x * b, a.y * b, a.z * b)
  end
end
function vec3:normalize()
  local len = self:lengh()
  self.x = self.x / len
  self.z = self.z / len
  self.y = self.y / len
  return self
end

---@return number
function vec3:lengh() return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z) end

---@param waypoints table<number,{redstone:number,position:{[1]:number,[2]:number,[3]:number }, address:string, label:string }>
---@return table<string,{ vec:vec3, redstone:number,address:string,label:string }>
---
function vec3.nodes_to_vec(waypoints)
  local out = {}
  for i, node in ipairs(waypoints) do
    local nodevec = vec3.new(node.position[1], node.position[2], node.position[3])
    out[node.label] = { vec = nodevec, redstone = node.redstone, address = node.address, label = node.label }
  end
  return out
end


vec3.ORIGIN = vec3.new(0, 0, 0)

return vec3
