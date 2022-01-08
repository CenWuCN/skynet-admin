local skynet = require "skynet"
local socket = require "skynet.socket"
local service = require "skynet.service"
local websocket = require "http.websocket"
local mc = require "skynet.multicast"
require "skynet.manager"

local handle = {}
local MODE = ...

if MODE == "agent" then
    local ConnectedAgentId = {}
    local ConnectedAgentCount = 0
    local websocket_router = require "websocket_router"
    local COMMAND = {
        ["log"] = "/debug/log",
        ["cpu"] = "/debug/cpu"
    }
    local channel = nil

    function handle.connect(id)
        print("ws connect from: " .. tostring(id))
    end

    function handle.handshake(id, header, url)
        local addr = websocket.addrinfo(id)
        websocket_router.set_id(url, id)
        print("ws handshake from: " .. tostring(id), "url", url, "addr:", addr)
        print("----header-----")
        for k,v in pairs(header) do
            print(k,v)
        end
        print("--------------")
    end

    function handle.message(id, msg, msg_type)
        assert(msg_type == "binary" or msg_type == "text")
        websocket.write(id, msg)
    end

    function handle.ping(id)
        print("ws ping from: " .. tostring(id) .. "\n")
    end

    function handle.pong(id)
        print("ws pong from: " .. tostring(id))
    end

    function handle.close(id, code, reason)
        websocket_router.remove_id(id)
    end

    function handle.error(id)
        websocket_router.remove_id(id)
    end

    skynet.start(function ()
        skynet.dispatch("lua", function (_,_, id, protocol, addr)
            local ok, err = websocket.accept(id, handle, protocol, addr)
            if not ok then
                print(err)
            end
        end)
        local channelid = skynet.getenv("websocket_channel")
        channel = mc.new({
            channel = tonumber(channelid),
            dispatch = function(channel, source, cmd, data)
                local url = assert(COMMAND[cmd])
                local url_func = websocket_router.get_url_func(url)
                if url_func then
                    for id in pairs(url_func.id_map) do
                        local ret, msg = pcall(websocket.write, id, url_func.func(data))
                        if not ret then
                            websocket_router.remove_id(url, id)
                            skynet.error(id .. msg)
                        end
                    end
                end
            end
        })
        channel:subscribe()
    end)
else
    local agent = {}

    skynet.start(function ()
        for i= 1, 1 do
            agent[i] = skynet.newservice(SERVICE_NAME, "agent")
        end
        local balance = 1
        local protocol = "ws"
        local id = socket.listen("0.0.0.0", 9948)
        skynet.error(string.format("Listen websocket port 9948 protocol:%s", protocol))
        socket.start(id, function(id, addr)
            skynet.send(agent[balance], "lua", id, protocol, addr)
            balance = balance + 1
            if balance > #agent then
                balance = 1
            end
        end)
    end)
end