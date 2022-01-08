local skynet = require "skynet"

skynet.start(function ()
    skynet.error("Server start")
    skynet.uniqueservice("system_monitor")
    skynet.newservice("debug_console",8000)
    skynet.newservice("web_service")
    skynet.newservice("websocket_service")
    
    skynet.exit()
end)