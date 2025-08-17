---@type kt_serialization
---@diagnostic disable-next-line
local bytearray = {}

local encoder = {}
local decoder = {}

bytearray.serialize = function(tbl) return '' end
bytearray.deserialize = function(value) return {} end

return bytearray
