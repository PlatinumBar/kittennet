---drone navigation (where self.move can get you to any point via a direct path)
local p = {}
local vec3 = require('003_veclib')
p.target_possition = vec3.new(0, 0, 0)

p.move_direct = self.move

function p:move_relative(x, y, z)
  self.target_possition = self.target_possition + vec3.new(x, y, z)
  self.move_direct(x, y, z)
end
---@param vec vec3
function p:move_relative_vec(vec)
  self.target_possition = self.target_possition + vec
  self.move_direct(vec.x, vec.y, vec.z)
end

function p:move_global(x, y, z)
  local target = vec3.new(x, y, z)
  local offset = self.target_possition - target

  self:move_relative_vec(offset)

  p.target_possition = target
end

function p:figure_it_out()
  -- require(
  -- '005_machine_id'
  -- ).hasComponent('navigation')
end
--
-- ---
-- ---@param pos1 vec3
-- ---@param pos2 vec3
-- ---@param pos3 vec3
-- ---@param pos4 vec3
-- ---@param d1 number
-- ---@param d2 number
-- ---@param d3 number
-- ---@param d4 number
-- ---@return boolean,vec3|nil
-- function p:triangulate(pos1, pos2, pos3, pos4, d1, d2, d3, d4)
-- do that later pls
--
--
--
-- end


return p
