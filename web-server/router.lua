local skynet = require "skynet"
local tinsert = table.insert
local smatch = string.match
local sgmatch = string.gmatch

local function timeout(ti)
	if ti then
		ti = tonumber(ti)
		if ti <= 0 then
			ti = nil
		end
	else
		ti = TIMEOUT
	end
	return ti
end

local function list()
    return skynet.call(".launcher", "lua", "LIST")
end

local function gc()
    return skynet.call(".launcher", "lua", "GC", timeout(ti))
end

local mem_reg = "([0-9%.]+% [a-zA-Z]+)"
local name_args_reg = "%((.+)%)"

local function parse_mem(data)
    local mem_info = {}
    mem_info.mem = smatch(data, mem_reg)
    mem_info.args = ""
    local name_args = smatch(data, name_args_reg)
    local index = 0
    for value in sgmatch(name_args, "[^%s]+") do
        index = index + 1
        if index == 1 then
            mem_info.type = value
        elseif index == 2 then
            mem_info.service = value
        else
            if index > 3 then
                mem_info.args = mem_info.args .. " "
            end
            mem_info.args = mem_info.args .. value
        end
    end
    return mem_info
end

local function mem()
    local mem_list = skynet.call(".launcher", "lua", "MEM", timeout(ti))
    local transfrom = {}
    for addr, data in pairs(mem_list) do
        local mem_info = parse_mem(data)
        mem_info.addr = addr
        tinsert(transfrom, mem_info)
    end
    return transfrom
end

local function stat()
    local stat_list = skynet.call(".launcher", "lua", "STAT", timeout(ti))
    local transfrom = {}
    for addr, data in pairs(stat_list) do
        tinsert(transfrom, {
            addr = addr,
            task = data.task,
            message = data.message,
            cpu = data.cpu,
            mqlen = data.mqlen
        })
    end
    return transfrom
end

local function service()
    return skynet.call("SERVICE", "lua", "LIST")
end

local function infolist()
    return skynet.call(".SystemMonitor", "lua", "getinfolist")
end

local function hostinfo()
    return skynet.call(".SystemMonitor", "lua", "gethostinfo")
end

local function sendmessage()
    skynet.error("print one line log")
end

local router = {
    ["/debug/list"] = list,
    ["/debug/gc"] = gc,
    ["/debug/mem"] = mem,
    ["/debug/stat"] = stat,
    ["/debug/service"] = service,
    ["/debug/infolist"] = infolist,
    ["/debug/hostinfo"] = hostinfo,
    ["/debug/sendmessage"] = sendmessage
}

return router