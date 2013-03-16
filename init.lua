local fancy = {}

fancy.cpu = require("cpu")

local cpu_timer = timer { timeout = 1}
cpu_timer:connect_signal("timeout",
  function()
    local usage = fancy.cpu.getCpuUsage()
    fancy.cpu:add_value(usage[1])
  end
)
cpu_timer:start()


return fancy
