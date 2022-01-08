local io = require "io"
local smatch = string.match
local tinsert = table.insert

local taskinfo = {}
local command = "top -bn1 -p 0"
local total_mem = nil
local host_info = {}

local cpu_id_reg = "([0-9%.]+)% id"
local mem_total_reg = "Mem[:% ]+([0-9%.]+)% total"
local mem_unit_reg = "([a-zA-Z]+)% Mem"
local mem_used_reg = "([0-9%.]+)% used"
local cpu_model_reg = "model name[%s]*:[%s]*([%g% ]*)"

function taskinfo.init()
    local output = taskinfo.get_proccess_info()
    total_mem = tonumber(smatch(output, mem_total_reg))
    local unit = smatch(output, mem_unit_reg)
    host_info.total_mem = total_mem .. " ".. unit
    taskinfo.cpu_model()
end

function taskinfo.cpu_model()
    local file = io.popen("cat /proc/cpuinfo")
    local output = file:read("a")
    file:close()
    host_info.cpu_model = smatch(output, cpu_model_reg)
end

function taskinfo.get_proccess_info()
    local file = io.popen(command)
    local output = file:read("a")
    file:close()
    return output
end

function taskinfo.parse_info(output)
    local info = {}
    tinsert(info, os.time() * 1000)
    tinsert(info, 100 - tonumber(smatch(output, cpu_id_reg)))
    tinsert(info, tonumber(smatch(output, mem_used_reg))/total_mem * 10000//1/100)
    return info
end

function taskinfo.get_host_info()
    return host_info
end

return taskinfo