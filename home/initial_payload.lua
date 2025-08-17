local CMD_PORT = 1234
local RESP_PORT = 1235
---@diagnostic disable-next-line:unused-local
local newline = string.char(10)
---@diagnostic disable-next-line:unused-local
local tabline = string.char(13)

---@diagnostic disable-next-line:lowercase-global
designation = 'bee' -- eg romanian, bee, local leader
---@diagnostic disable-next-line:lowercase-global
function cmp_lookup(name)
  if component.isAvailable(name) then
    return component.proxy(component.list(name)())
  else
    return nil
  end
end

--#region remove

---@class computer
---@type computer
_G.computer = _G.computer -- useless shit to make the lsp understand what a computer is
---@type component
---@class component
_G.component = _G.component

--#endregion remove
---@class drone
_G.self = cmp_lookup('drone') or cmp_lookup('robot')

---@type debug
---@diagnostic disable-next-line:assign-type-mismatch
_G.dbg = cmp_lookup('debug')

---@param str string
function _G.say(str)
  if _G.dbg ~= nil then
    _G.dbg.runCommand('/say ' .. str)
  else
    if component.isAvailable('debug') then _G.dbg = component.proxy(component.list('debug')()) end
  end
end ---@type modem
_G.modem = component.proxy(component.list('modem')())

say('init')

modem.open(CMD_PORT)
modem.open(RESP_PORT)
---@type table<string,function>

---@diagnostic disable-next-line:lowercase-global
signal_callbacks = {}
---@type table<string,function>
---@diagnostic disable-next-line:lowercase-global
net_callbacks = {}

---assumes that stringinfo is just code, no packing, no compression
net_callbacks.c_exec = function(_, _, _, stringinfo)
  local f, err = load(stringinfo, 'c_exec', 't')
  if not f then
    say('compilation error:' .. err)
  else
    local ok, errp = pcall(f)
    if not ok then say('execution error:' .. errp) end
  end
end
net_callbacks.fmwr = function(_, _, _, stringinfo)
  ---@class eeprom
  eeprom = cmp_lookup('eeprom').set(stringinfo)
  computer.shutdown(true)
end

---@param data table
signal_callbacks.modem_message = function(data)
  local _, _, remote_addr, port, distance, packet_type, stringinfo = table.unpack(data)
  if net_callbacks[packet_type] ~= nil then
    local ok, err = pcall(net_callbacks[packet_type], remote_addr, port, distance, stringinfo)
    if not ok then say('modem_callback_message error: ' .. err) end
  end
end

while true do
  local info = table.pack(computer.pullSignal(0.5))
  if info[1] and info ~= nil then
    if signal_callbacks[info[1]] ~= nil then
      local ok, err = pcall(signal_callbacks[info[1]], info)
      if not ok then say('error: ' .. tostring(err)) end
    end
  else
    ---@diagnostic disable-next-line:undefined-field
    if type(_G.no_info_cb) == 'function' then pcall(_G.no_info_cb) end
  end
end
