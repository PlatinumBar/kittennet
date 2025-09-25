---@param s string
function exec(s) require('component').modem.broadcast(5555, 'c_exec', s) end
exec('p = require("008_polaris") v = require("003_veclib")')
exec('p:move_relative_vec(v.new(0,3,5))')

function spam()
  exec(string.format('timeout1=computer.uptime()'))
  for i = 1, 20 do
    exec(string.format('say(%q)', string.format('val %d', i)))
  end
  exec(string.format('timeout2=computer.uptime() say("diff:"..tostring(timeout2-timeout1))'))
end

computer = {}
function computer.freeMemory() return 50000 end

function computer.totalMemory() return 2 << 18 end
