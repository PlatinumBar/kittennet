---@meta _
---@class session
---@field thread thread
---@field uuid string # uuid of the opponent
---@field timeout number
---@field closer fun(selfref:session)|nil
---@type session
local s = {}
return s
