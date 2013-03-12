local awful = require("awful")
local pretty = require("pl.pretty")

local fancy = {}

fancy.cpu = awful.widget.graph()
fancy.cpu:set_width(50)
fancy.cpu:set_color("#FF5656")
fancy.cpu:set_max_value(100)

local cpu_usage = {}
local cpu_total = {}

local cpu_values = {}
local file = io.open("/proc/stat")
for line in file:lines() do
  -- Its safe to break since cpu lines are always on the top of /proc/stat
  if string.sub(line, 1, 3) ~= "cpu" then
    break
  end

  local values = {}
  for value in string.gmatch(line, "[%s]+([^%s]+)") do
    table.insert(values, value)
  end
  table.insert(cpu_values, values)
end
file:close()

-- pretty.dump(cpu_values)

-- The percentage is given by
-- (user + nice + system ) / total
for i, values in ipairs(cpu_values) do
  local total = 0
  for j = 1, #values do
    total = total + values[j]
  end

  table.insert(cpu_usage, ((values[1] + values[2] + values[3]) / total) * 100)
end

pretty.dump(cpu_usage)

fancy.cpu:add_value(cpu_usage[0])

return fancy
