---@type kt_serialization
---@diagnostic disable-next-line
---
--[[TYPES: (most not used, this is for further expansion i guess, just copied the format strings docs page and assigned a number)
--the numbers go like TYPE -> value -> TYPE (3) value value value
0x0 = false
0x1 = true
^^^ these still take a byte though, bit shift into a byte if you need multiple 
0x2 = unsigned byte
0x3 = unsigned short 
0x4 = unsigned long 
0x5 = lua_integer
add 4 to get unsigned
0x6 = signed byte
0x7 = signed short 
0x8 = signed long 
0x9 = lua_unsigned
0xa = size_t
0xb B = signed int with BYTE bytes in it 
(so like you write 0xb + amount of elements as a byte, not sure if thats ever going to be useful)
0xc B = unsigned int with BYTE bytes in it
0xd = float
0xf = double
0x10 = lua number (the lazy method)
0x11 B = array of chars B characters long
0x12 L = array of chars L characters long
0x13 = nil 
0x14 = zero terminated string / C style string

0x15 key value pair table
0x16 array table (where the key is numbers 1..#tbl )

since this is < 0x20 opcodes, it fits into 5 bits, which means that if you spend enough time you can probably do that

--]]
---@diagnostic disable:redefined-local
---@diagnostic disable-next-line:missing-fields
local m = {}
local OPCODE_COUNT = 0x16 + 1 -- the amount of types in the comments above + 1
--this is required for when a byte is above OPCODE_COUNT and bellow 255 meaning that you can cheese yourself some space there
--save on a few end result characters by getting the shortened function name
local sp = string.pack
local up = string.unpack
----# turn a type(input) into a function that takes in num and outputs a string
local encoder = {}
local decoder = {}

--TODO: remove this, this was for debugging
function string.tohex(str)
  return (str:gsub('.', function(c) return string.format('%02X', string.byte(c)) end))
end
---math.type can return "float" "integer" and "nil"
---@param num number
encoder.number = function(num) return encoder[math.type(num)](num) end
encoder['nil'] = '\x13'
---@param num integer
----@param negative boolean|nil
encoder.integer = function(num)
  local negative = num < 0
  if negative then num = -num end
  local o = negative and 4 or 0 -- add 4 to the opcode to turn a signed into an unsigned
  if num > OPCODE_COUNT and num < 256 then
    return sp('B', num)
  elseif num < 256 ^ 1 then
    return sp('BB', 0x02 + o, num)
  elseif num < 256 ^ 2 then
    return sp('BH', 0x03 + o, num)
  elseif num < 256 ^ 4 then
    return sp('BL', 0x04 + o, num)
  else
    return sp('BJ', 0x05 + o, num)
  end
end
encoder.float = function(num) return sp('Bd', 0xf, num) end
---@param str string
encoder.string = function(str)
  --removing this cuts down on quite a few cycles but increases memory usage
  local function is_ascii(str2)
    for i = 1, #str2 do
      local byte = string.byte(str2, i)
      --ASCII range is 1-127 ish
      if byte < 1 or byte > 127 then return false end
    end
    return true
  end
  if is_ascii(str) then return sp('Bz', 0x14, str) end
  if #str < 256 then
    return sp('BB', 0x11, #str) .. str
  else
    return sp('BL', 0x12, #str) .. str
  end
end
---@param bool boolean
encoder.boolean = function(bool) return sp('B', (bool and 1) or 0) end

---@param tbl table
encoder.table = function(tbl)
  local function isArray(tbl2)
    local i = 1
    for k, _ in pairs(tbl2) do
      if k ~= i then return false end
      i = i + 1
    end
    return true
  end
  local function count_table(t)
    local count = 0
    for _ in pairs(t) do
      count = count + 1
    end
    return count
  end
  local isarray = isArray(tbl)

  if isarray then
    local s = sp('B', 0x16) .. safe_encode(#tbl) -- 0x16 .. size of the array .. (...elements...)
    for _, v in ipairs(tbl) do
      s = s .. safe_encode(v)
    end
    return s
  else
    local s = sp('B', 0x15)
    s = s .. safe_encode(count_table(tbl))
    for k, v in pairs(tbl) do
      if type(k) ~= 'number' and type(k) ~= 'string' then error('tried to encode an invalid table') end
      s = s .. safe_encode(k)
      s = s .. safe_encode(v)
    end
    return s
  end
end

---@param value any
---@return string
function safe_encode(value)
  if encoder[type(value)] ~= nil then
    return encoder[type(value)](value)
  else
    return encoder[type(nil)](nil)
  end
end

local function decode(str, offset)
  local b, o = up('B', str, offset)
  if decoder[b] ~= nil then
    local v, o = decoder[b](str, o)
    return v, o
  else
    return b, o --assume that its a byte with nothing else to it if its not in the decoder table
  end
end

decoder[0x0] = function(str, offset) return false, offset end
decoder[0x1] = function(str, offset) return true, offset end
decoder[0x2] = function(str, offset) return up('B', str, offset) end
decoder[0x3] = function(str, offset) return up('H', str, offset) end
decoder[0x4] = function(str, offset) return up('L', str, offset) end
decoder[0x5] = function(str, offset) return up('J', str, offset) end

decoder[0x6] = function(str, offset) return up('b', str, offset) end
decoder[0x7] = function(str, offset) return up('h', str, offset) end
decoder[0x8] = function(str, offset) return up('l', str, offset) end
decoder[0x9] = function(str, offset) return up('j', str, offset) end
decoder[0xa] = function(str, offset) return up('T', str, offset) end
decoder[0xb] = function(str, offset)
  local bt = up('B', str, offset)
  return up('i' .. tostring(bt), str, offset + 1)
end
decoder[0xc] = function(str, offset)
  local bt = up('B', str, offset)
  return up('I' .. tostring(bt), str, offset + 1)
end
decoder[0xd] = function(str, offset) return up('f', str, offset) end
decoder[0xf] = function(str, offset) return up('d', str, offset) end
decoder[0x10] = function(str, offset) return up('n', str, offset) end
decoder[0x11] = function(str, offset)
  local N, nof = up('B', str, offset)
  return up('c' .. tostring(N), str, nof)
end
decoder[0x12] = function(str, offset)
  local N, nof = up('L', str, offset)
  return up('c' .. tostring(N), str, nof)
end
decoder[0x13] = function(str, offset) return nil, offset end
decoder[0x14] = function(str, offset) return up('z', str, offset) end
decoder[0x15] = function(str, offset)
  local result, size, offset = {}, 0, offset -- end table, table element count, offset
  size, offset = decode(str, offset)
  if size >= 1 then
    for _ = 1, size do
      local key, n1 = decode(str, offset)
      offset = n1
      local value, n2 = decode(str, offset)
      offset = n2
      result[key] = value
    end
  else
    return result, offset
  end
  return result, offset
end
decoder[0x16] = function(str, offset)
  local result, size, offset = {}, 0, offset
  size, offset = decode(str, offset)
  if size >= 1 then
    for i = 1, size do
      local value, newo = decode(str, offset)
      result[i] = value
      offset = newo
    end
    return result, offset
  else
    return result, offset
  end
end

---@param tbl table
---@return boolean
m.serialize = function(tbl) return encoder[type(tbl)](tbl) end

m.deserialize = function(value)
  local result, offset = {}, 1
  while offset < #value do
    local code, o = up('B', value, offset)
    offset = o
    if decoder[code] == nil then
      table.insert(result, code) -- assume that its a byte
    end
    local value, newoffset = decoder[code](value, offset)
    offset = newoffset
    table.insert(result, value)
  end
  ---@diagnostic disable-next-line # shut up computer
  return table.unpack(result)
end

return m
