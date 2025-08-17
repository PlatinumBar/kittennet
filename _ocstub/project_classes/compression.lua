---@meta
---@abstract
---@class compressor
local compressor = {}
---@param bytearray string
---@return boolean,string|nil
function compressor.deflate(bytearray) end

---@param bytearray string
---@return boolean,string|nil
function compressor.zip(bytearray) end
