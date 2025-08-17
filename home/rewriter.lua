local path = table.pack(...)
assert(path.n > 1, 'name.lua <file> <flag> you dumbass\n -w to write to eeprom\n -r to run')
local function save(fpath, str)
  local fs = require('filesystem')
  local f, err = fs.open(fpath, 'w')
  if not f then error(err) end
  f:write(str)
  f:close()
end -- usage

local f = assert(io.open(path[1], 'rb'))
local s = f:read('*a')
f:close()
local modem = assert(require('component').modem)
local function strip_comments(str)
  str = str:gsub('%-%-%[%[.-%]%]', '')
  str = str:gsub('%-%-.-\n', '\n')
  return str
end
--optional? not really if \n is removed
s = strip_comments(s)

s = s:gsub('"', "'")
s = s:gsub('[\r\n]+', ' ')

while s:find('  ') do
  s = s:gsub('  ', ' ')
end
while s:find(', ') do
  s = s:gsub(', ', ',')
end
while s:find(' = ') do
  s = s:gsub(' = ', '=')
end
while s:find('{ ') do
  s = s:gsub('{ ', '{')
end
while s:find(' }') do
  s = s:gsub(' }', '}')
end

if string.len(s) > 4096 then error('too much space used, currently at ' .. string.len(s) .. 'b') end
if path[2] == '-w' then
  modem.broadcast(1234, 'fmwr', s)
else
  modem.broadcast(1234, 'c_exec', s)
end

print('just wrote ' .. string.len(s) .. ' bytes')

save('/tmp/lastwrite', s)
