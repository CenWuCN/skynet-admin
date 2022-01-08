local taskinfo = require "taskinfo"

taskinfo.init()

local output = taskinfo.get_proccess_info()
print(output)
local info = taskinfo.parse_info(output)
local host_info = taskinfo.get_host_info()
for k, v in pairs(info) do
    print(k, v)
end
for k, v in pairs(host_info) do
    print(k, v)
end

local a = "ws"
local b = "ws"
print(a == b)

print(os.date("%Y%m%d-%H:%M:%S", 1641489544))
print(1641489544.12//1)