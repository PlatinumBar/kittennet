---@meta _

---@class nettask
---@field timeout number # remove at start time + timeout
---@field resumable thread
---@field stime number # start time
---@field failure_function function|nil
---@type nettask
local nt = {}
nt.timeout = 5
nt.resumable = coroutine.create(function() end)

return nt
