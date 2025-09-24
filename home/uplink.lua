local fs = require('filesystem')
local args = table.pack(...)
local path = fs.realPath(args[1])
local modem = require('component').modem
if not modem then error('no modem') end
for file in fs.list(path) do
  print(string.format('uploading %s', file))
  local file_contents = io.open(fs.realPath(file), 'r'):read('*a')
  modem.broadcast(5555, 'c_exec', string.format('local function module() %s end _G.modules[%q]=module()', file_contents, fs.realPath(path)))
end
