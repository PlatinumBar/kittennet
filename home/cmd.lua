---@param s string
function exec(s) require('component').modem.broadcast(5555, 'c_exec', s) end  function spam()   exec(string.format('timeout1=computer.uptime()'))   for i = 1, 20 do     exec(string.format('say(%q)', string.format('val %d', i)))   end   exec(string.format('timeout2=computer.uptime() say("diff:"..tostring(timeout2-timeout1))')) end 
