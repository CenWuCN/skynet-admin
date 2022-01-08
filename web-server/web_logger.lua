local skynet = require "skynet"
local io = require "io"
local osdate = os.date
require "skynet.manager"

local channel = nil
local log = "log"
local file = io.open("weblog", "w+")
if not file then
	print("log file weblog open failed" .. msg)
	return
end

local COMMAND = {}
function COMMAND.set_channel()
	local mc = require "skynet.multicast"
	local id = skynet.getenv("websocket_channel")
	channel = mc.new({
		channel = tonumber(id)
	})
end

-- register protocol text before skynet.start would be better.
skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
		local logtext = string.format(":%08x(%s): %s", address, osdate("%Y%m%d-%H:%M:%S"), msg)
		print(logtext)
		local logtext = logtext .. "\n"
		if channel then
			channel:publish(log, logtext)
		end
		if file then
			file:write(logtext)
			file:flush()
		end
	end
}

skynet.register_protocol {
	name = "SYSTEM",
	id = skynet.PTYPE_SYSTEM,
	unpack = function(...) return ... end,
	dispatch = function()
		-- reopen signal
		print("SIGHUP")
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(COMMAND[cmd])
		f(...)
	end)
	skynet.register(".Web_logger")
end)