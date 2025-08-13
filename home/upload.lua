local path = ...
assert(path, 'name.lua <file> you dumbass')
local function save(fpath, str)
  local fs = require('filesystem')
  local f, err = fs.open(fpath, 'w')
  if not f then error(err) end
  f:write(str)
  f:close()
end

-- usage

local f = assert(io.open(path, 'rb'))
local s = f:read('*a')
f:close()
local modem = assert(require('component').modem)

modem.broadcast(1234, 's_exec', "_G.eeprom = component.proxy(component.list('eeprom')())")
modem.broadcast(1234, 's_exec', "_G.eeprom = component.proxy(component.list('eeprom')())")
