local req = _G.require
if type(req) ~= 'function' then
  ---@param modname string
  ---@return table
  _G.require = function(modname) return _G.modules[modname] end
end
