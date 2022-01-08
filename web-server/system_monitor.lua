local skynet = require "skynet"
local mc = require "skynet.multicast"
require "skynet.manager"
local taskinfo = require "taskinfo"
local tinsert = table.insert
local tremove = table.remove

local info_list = {}
local info_list_max_len = 120

local Monitor = {}
local channel = nil
local cpu = "cpu"

local function add_info(info)
    tinsert(info_list, info)
    if #info_list > info_list_max_len then
        tremove(info_list, 1)
    end
end

local function main_loop()
    local output = taskinfo.get_proccess_info()
    local info = taskinfo.parse_info(output)
    add_info(info)
    channel:publish(cpu, info)
    skynet.timeout(500, main_loop)
end

function Monitor.getinfolist()
    return info_list
end

function Monitor.gethostinfo()
    return taskinfo.get_host_info()
end

skynet.start(function()
    taskinfo.init()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = assert(Monitor[cmd])
		skynet.ret(skynet.pack(f(...)))
    end)
    channel = mc.new()
    skynet.setenv("websocket_channel", channel.channel)
    skynet.send(".Web_logger", "lua", "set_channel")
    skynet.timeout(0, main_loop)
    skynet.register(".SystemMonitor")
end)