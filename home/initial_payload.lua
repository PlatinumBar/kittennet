local CMD_PORT = 1234
local RESP_PORT = 1235
local newline = string.char(10)
local tabline = string.char(13)
---@param str string
function say(str) dbg.runCommand('/say ' .. str) end

--#region remove
---@class computer
---@type computer
_G.computer = _G.computer -- useless shit to make the lsp understand what a computer is
---@type component
---@class component
_G.component = _G.component
--#endregion remove
say('init')
  _G.self = component.proxy(component.list('drone')())
---@type debug
_G.dbg = component.proxy(component.list('debug')())
---@type modem
_G.modem = component.proxy(component.list('modem')())
modem.open(CMD_PORT)
modem.open(RESP_PORT)
---@type table<string,function>
---@diagnostic disable-next-line
callbacks = {}
---@type table<string,function>
---@diagnostic disable-next-line
net_callbacks = {}

---assumes that stringinfo is just code, no packing, no compression
net_callbacks.c_exec = function(from, port, distance, stringinfo)
  local f, err = load(stringinfo, 'c_exec', 't')
  if not f then
    say('compilation error:' .. err)
  else
    local ok, errp = pcall(f)
    if not ok then say('execution error:' .. errp) end
  end
end

---@param data table
callbacks.modem_message = function(data)
  local event_name, receiver_addr, sender_addr, port, distance, packet_type, stringinfo = table.unpack(data)
  say('received: ' .. table.concat(data, '|'))
  if net_callbacks[packet_type] ~= nil then
    local ok, err = pcall(net_callbacks[packet_type], receiver_addr, port, distance, stringinfo)
    if not ok then say('modem_callback_message error: ' .. err) end
  end
end

while true do
  local info = table.pack(computer.pullSignal(0.5))
  if info[1] and info ~= nil then
    if callbacks[info[1]] ~= nil then
      local ok, err = pcall(callbacks[info[1]], info)
      if not ok then say('error: ' .. tostring(err)) end
    end
  else
    if type(_G.no_info_cb) == 'function' then pcall(_G.no_info_cb) end
  end
end
