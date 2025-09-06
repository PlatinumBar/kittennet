local req = _G.require
if type(req) ~= 'function' then
  ---@param modname string
  _G.require = function(modname) return _G.modules[modname] end
end
