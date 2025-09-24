local CMD_PORT = 1234

--- these have to exist because the bloat stripper will shit itself if you use the character
-- ---@diagnostic disable-next-line:unused-local
-- local newline = string.char(10)
-- ---@diagnostic disable-next-line:unused-local
-- local tabline = string.char(13)

designation = 'bee' -- eg romanian, bee

local function cmp_lookup(name)
  if component.list(name) ~= {} then
    return component.proxy(component.list(name)())
  else
    return nil
  end
end
_G.cmp_lookup = cmp_lookup
--#region remove

---@class computer
---@type computer
_G.computer = _G.computer -- useless shit to make the lsp understand what a computer is
---@type component
---@class component
_G.component = _G.component

--#endregion remove
---@class drone
_G.self = cmp_lookup('drone') or cmp_lookup('robot') or cmp_lookup('tablet') or cmp_lookup('microcontroller')
self.rname = self.name()
self.setStatusText(self.rname)

---@type debug
---@diagnostic disable-next-line:assign-type-mismatch
_G.dbg = cmp_lookup('debug')
---@type modem
---@diagnostic disable-next-line:assign-type-mismatch
_G.modem = cmp_lookup('modem')

---@param str string
function _G.say(str)
  if _G.dbg ~= nil then _G.dbg.runCommand('/say ' .. str) end
end

modem.open(CMD_PORT)
---@type table<string,function>

signal_callbacks = {}
---@type table<string,fun(remote_addr:string, port:number, distance:number, stringinfo:string)>
net_callbacks = {}

---@type table<string,table>
---stuff to store code chunks
modules = {}

---@type table<string,table>
cortex = {} --stuff to store network information i guess

---assumes that stringinfo is just code, no packing, no compression
net_callbacks.c_exec = function(_, _, _, stringinfo)
  local f, err = load(stringinfo, 'c_exec', 't')
  if not f then
    say('compilation error:' .. err)
    return
  else
    local ok, errp = pcall(f)
    if not ok then
      say('execution error:' .. errp)
      return
    end
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
  if net_callbacks[packet_type] then
    local ok, err = pcall(net_callbacks[packet_type], remote_addr, port, distance, stringinfo)
    if not ok then
      say('modem_callback_message error: ' .. err)
      computer.pushSignal('exception', 'modem_message', err)
      return
    end
  end
end

pullInterval = 1

mainfunc = function()
  local info = table.pack(computer.pullSignal(pullInterval)) -- this is a bad idea but i think it saves energy
  if info[1] and info ~= nil then
    if signal_callbacks[info[1]] ~= nil then
      local ok, err = pcall(signal_callbacks[info[1]], info)
      if not ok then
        say('error: ' .. tostring(err))
        computer.pushSignal('exception', 'main loop')
      end
    end
  else
    ---@diagnostic disable-next-line:undefined-field
    if type(_G.no_info_cb) == 'function' then pcall(_G.no_info_cb) end
  end
end
clock = computer.uptime()
say('init')
while true do
  mainfunc()
end
