local awful = require("awful")
local pretty = require("pl.pretty")

local fancy = {}

fancy.cpu = awful.widget.graph()
fancy.cpu:set_width(50)
fancy.cpu:set_color("#FF5656")
fancy.cpu:set_background_color('#494B4F')
--fancy.cpu:set_gradient_colors({ '#FF5656', '#88A175', '#AECF96' })
--fancy.cpu:set_max_value(100)

local cpu_usage = {}
local prev_total = {}
local prev_idle = {}

local function getCpuUsage()
  local file = io.open("/proc/stat")
  -- Important to clean previous values
  cpu_usage = {}
  local idle = {}
  local total = {}


  local nline = 1
  for line in file:lines() do
    -- Its safe to break since cpu lines are always on the top of /proc/stat
    if string.sub(line, 1, 3) ~= "cpu" then
      break
    end

    -- proc/stat cpu line is
    -- core, user, nice, system, and idle
    local values = {}
    for value in string.gmatch(line, "[%s]+([^%s]+)") do
      table.insert(values, value)
    end
    table.insert(idle, values[4])

    local line_total = 0
    for j = 1, #values do
      line_total = line_total + values[j]
    end
    table.insert(total, line_total)


    -- First run fills
    if prev_idle[nline] == nil or prev_total[nline] == nil then
      table.insert(cpu_usage, 0)
    else
      local diff_idle = idle[nline] - prev_idle[nline]
      local diff_total = total[nline] - prev_total[nline]

      table.insert(cpu_usage, 1 - (diff_idle / diff_total))
    end

    prev_idle[nline] = idle[nline]
    prev_total[nline] = total[nline]

    nline = nline + 1
  end
  file:close()

  pretty.dump(cpu_usage)

  return cpu_usage
end

local cpu_timer = timer { timeout = 1}
cpu_timer:connect_signal("timeout",
  function()
    local usage = getCpuUsage()
    fancy.cpu:add_value(usage[1])
  end
)
cpu_timer:start()

return fancy
