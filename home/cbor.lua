---@type kt_serialization
---@diagnostic disable-next-line
local cbor = {}

local encoder = {}
local decoder = {}


cbor.serialize = function(tbl) end
cbor.deserialize = function(value) return {} end

return cbor
