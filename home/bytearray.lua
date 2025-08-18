---@type kt_serialization
---@diagnostic disable-next-line
--[[TYPES: (most not used, this is for further expansion i guess, just copied the format strings docs page and assigned a number)
0x0 = false
0x1 = true
^^^ these still take a byte though, bit shift into a byte if you need multiple 
0x2 = signed byte
0x3 = unsigned byte
0x4 = signed short 
0x5 = unsigned short 
0x6 = signed long 
0x7 = unsigned long 
0x8 = lua_integer
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
---@diagnostic disable-next-line:missing-fields
local m = {}
--save on a few end result characters by getting the shortened function name
local sp = string.pack
local up = string.unpack
local encoder = {}
local decoder = {}

---math.type can return "float" "integer" and "nil"
---@param num number
encoder.number = function(num) return encoder[math.type(num)](num) end
encoder['nil'] = '\x13'
---@param num integer
encoder.integer = function(num) end

m.serialize = function(tbl) return encoder[type(tbl)](tbl) end
m.deserialize = function(value) return {} end

return m
