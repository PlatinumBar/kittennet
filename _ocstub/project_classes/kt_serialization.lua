---@meta "kt_serialization"

---@class kt_serialization
---@field serialize fun(tbl:table):string|nil
---@field deserialize fun(value:string):table|nil
local serialization = {}

---table -> string for network transmission.
---@param tbl table
---@return string|nil # string to deserialize
function serialization.serialize(tbl) end

---string -> table.
---@param value string #string to be deserialized
---@return table|nil # table restored from the string
function serialization.deserialize(value) end

return serialization
