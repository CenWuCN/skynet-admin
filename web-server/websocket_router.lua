local cjson = require "cjson"

local function log(text)
    return text
end
local function cpu(data)
    local text = cjson.encode(data)
    return text
end

local url_func = {
    ["/debug/log"] = { func = log, id_map = {} },
    ["/debug/cpu"] = { func = cpu, id_map = {} }
}

local websocket_router = {}

function websocket_router.get_url_func(url)
    return url_func[url]
end

function websocket_router.set_id(url, id)
    local map = url_func[url]
    if map and map.id_map then
        map.id_map[id] = true
    end
end

function websocket_router.remove_id(url, id)
    local map = url_func[url]
    if map and map.id_map then
        map.id_map[id] = nil
    end
end

return websocket_router