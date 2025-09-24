---@meta _
---@class task
---@field func thread
---@field prio number
---@field type string
---@field default number
---@type task
task = {
  ---@type function
  func = function() end,
  prio = 0,
  type = '',
  default = 5,
}
