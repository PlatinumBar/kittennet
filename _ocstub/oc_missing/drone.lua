---@meta _

---@class drone : BaseComponent
---@field type "drone"
local d = {}

---Get the status text currently being displayed in the GUI.
---@return string
function d.getStatusText() end

---Set the status text to display in the GUI, returns new value.
---@param value string
---@return string
function d.setStatusText(value) end

---Change the target position by the specified offset.
---@param dx number
---@param dy number
---@param dz number
function d.move(dx, dy, dz) end

---Get the current distance to the target position.
---@return number
function d.getOffset() end

---Get the current velocity in m/s.
---@return number
function d.getVelocity() end

---Get the maximum velocity, in m/s.
---@return number
function d.getMaxVelocity() end

---Get the currently set acceleration.
---@return number
function d.getAcceleration() end

---Try to set the acceleration to the specified value and return the new acceleration.
---@param value number
---@return number
function d.setAcceleration(value) end

---Get the name of the robot.
---@return string
function d.name() end

---Uses the tool against the block or entity in front.
---@param side number
---@return boolean, string|nil
function d.swing(side) end

---Attempts to use the item currently equipped in the tool slot.
---@param side number
---@param sneaky? boolean
---@param duration? number
---@return boolean,string
function d.use(side, sneaky, duration) end

---Tries to place the block in the selected slot on the specified side.
---@param side number
---@param sneaky? boolean
---@return boolean, string|nil
function d.place(side, sneaky) end

---Get the current color of the flap light as integer encoded RGB (0xRRGGBB).
---@return number
function d.getLightColor() end

---Set the color of the flap light.
---@param value number
---@return number
function d.setLightColor(value) end

---Returns the size of the device's internal inventory.
---@return number
function d.inventorySize() end

---Get or set the selected slot.
---@param slot? number
---@return number
function d.select(slot) end

---Get the number of items in the specified slot (default: selected).
---@param slot? number
---@return number
function d.count(slot) end

---Get the remaining space in the specified slot (default: selected).
---@param slot? number
---@return number
function d.space(slot) end

---Compare the contents of the selected slot to another slot.
---@param otherSlot number
---@return boolean
function d.compareTo(otherSlot) end

---Move items from selected slot to another slot.
---@param toSlot number
---@param amount? number
---@return boolean
function d.transferTo(toSlot, amount) end

---Returns the number of tanks installed.
---@return number
function d.tankCount() end

---Select the specified tank.
---@param tank number
function d.selectTank(tank) end

---Returns fluid level in a tank (default: selected).
---@param tank? number
---@return number
function d.tankLevel(tank) end

---Returns remaining fluid capacity in a tank (default: selected).
---@param tank? number
---@return number
function d.tankSpace(tank) end

---Tests if the fluid in selected tank matches the one in another tank.
---@param tank number
---@return boolean
function d.compareFluidTo(tank) end

---Transfer fluids between tanks.
---@param tank number
---@param count? number
---@return boolean
function d.transferFluidTo(tank, count) end

---Detects the block on a side; returns true if it blocks movement.
---@param side number
---@return boolean
function d.detect(side) end

---Compares selected tank's fluid with world/external tank.
---@param side number
---@return boolean
function d.compareFluid(side) end

---Extract fluids from world/tank.
---@param side number
---@param count? number
---@return boolean
function d.drain(side, count) end

---Fills world/tank from selected tank.
---@param side number
---@param count? number
---@return boolean
function d.fill(side, count) end

---Compares the block on a side with the selected slot's item.
---@param side number
---@param fuzzy? boolean
---@return boolean
function d.compare(side, fuzzy) end

---Drops items from selected slot to the given side.
---@param side number
---@param count? number
---@return boolean
function d.drop(side, count) end

---Tries to pick up items into the selected slot.
---@param side number
---@param count? number
---@return number|false
function d.suck(side, count) end

return d
