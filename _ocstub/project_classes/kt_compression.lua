---@meta "kt_compressor"
---@abstract
---@class kt_compressor
---@field zip fun(input:string):string|nil
---@field deflate fun(input:string):string|nil
local compressor = {}
---@param bytearray string
---@return boolean,string|nil
function compressor.deflate(bytearray) end

---@param bytearray string
---@return boolean,string|nil
function compressor.zip(bytearray) end
