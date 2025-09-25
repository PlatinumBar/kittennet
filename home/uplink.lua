local fs = require('filesystem')
local args = table.pack(...)
local path = fs.realPath(args[1] or '/home/drone')
local modem = require('component').modem
if not modem then error('no modem') end
local reals = {}
local sn = {}
local first = true
for file in fs.list(path) do
  local fullpath = fs.concat(path, file)
  if not fs.isDirectory(fullpath) then
    table.insert(reals, fullpath)
    sn[fullpath] = file:sub(1, #file - 4)
  end
end
table.sort(reals)

for _, file in ipairs(reals) do
  if first then
    first = false
    print('skipping ' .. file)
    goto continue
  end

  --local fullpath = fs.concat(path, file)
  local file_contents = io.open(file, 'r'):read('*a')
  if not file_contents then goto continue end
  local function strip_comments(str)
    str = str:gsub('%-%-%[%[.-%]%]', '')
    str = str:gsub('%-%-.-\n', '\n')
    return str
  end

  s = strip_comments(file_contents)

  -- s = s:gsub('"', "'")
  -- s = s:gsub('[\r\n]+', ' ')
  --
  -- while s:find('  ') do
  --   s = s:gsub('  ', ' ')
  -- end
  -- while s:find(', ') do
  --   s = s:gsub(', ', ',')
  -- end
  -- while s:find(' = ') do
  --   s = s:gsub(' = ', '=')
  -- end
  -- while s:find('{ ') do
  --   s = s:gsub('{ ', '{')
  -- end
  -- while s:find(' }') do
  --   s = s:gsub(' }', '}')
  -- end
  ---@cast file string
  local code = string.format('local function module() %s end\n _G.say(%q)\n _G.modules[%q]=module()', s, file:sub(1, #file - 4), sn[file])
  -- print(
  --   string.format('pseudo: local function module() end\n _G.say(%q) _G.say(%q)\n _G.modules[%q]=module()', file:sub(1, #file - 4), sn[file], sn[file])
  -- )
  print(string.format('uploading %s (%db)', file, #code))
  modem.broadcast(5555, 'c_exec', code)
  ::continue::
end
