local json = require('Discraft/json_utils')
local colors = require('Discraft/color_utils')

local discord = {}

-- Util for Discord based API functions
local api_url = "https://discord.com/api/v10"

-- Gateway stuff
local gateway = nil
local ws = nil

-- Declare the token and channel id
local discord_token = nil
local discord_channel_id = nil

-- Read the token and channel id from the config file
if fs.exists('config.json') then
    print('Loading discord related settings from config file...')

    local config_file = fs.open('config.json', 'r')
    local config = json.decode(config_file.readAll())
    config_file.close()

    if config.bot_token and config.channel_id then
        discord_token = config.bot_token
        discord_channel_id = config.channel_id
    else
        error('Config file is missing discord_token or discord_channel_id')
    end
else
    error('Config file not found')
end

-- Check if channel is valid and bot is authorized
function discord.check_connection()
    local url = api_url .. "/channels/" .. discord_channel_id
    local headers = {
        ["Authorization"] = "Bot " .. discord_token,
        ["Accept"] = "application/json",
    }

    local response = http.get(url, headers)
    if response then
        local data = json.decode(response.readAll())
        response.close()

        if data.code == nil then
            -- Fetch gateway url
            url = api_url .. "/gateway/bot"
            local gateway_response = http.get(url, headers)

            if gateway then
                gateway = json.decode(gateway_response.readAll())
                gateway_response.close()
            end

            return true
        else
            return false
        end
    else
        return false
    end
end

-- Send discord embed function to channel
function discord.send_embed(title, description, color)
    -- Build embed
    local embed = {}
    embed.title = title
    embed.description = description
    embed.color = color or colors.default()
    embed.timestamp = os.date("%Y-%m-%dT%H:%M:%S%z")

    -- Send embed to channel
    local url = api_url .. "/channels/" .. discord_channel_id .. "/messages"
    local body = {}
    body.embeds = { embed }
    body = json.encode(body)

    local headers = {
        ["Authorization"] = "Bot " .. discord_token,
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
    }

    if body ~= nil then
        local response = http.post(url, body, headers)

        if response.getResponseCode() == 200 then
            return true
        end
    end

    return false
end

local Events = {}
local sequence = nil
local heartbeat_interval = 5
local send_once = false
local ready = false

function discord.ws_send(data)
    if not ws then
        print("Websocket not connected, unable to send data")
        return
    end

    local success, err = pcall(function()
        ws.send(json.encode(data))
    end)

    if not success then
        -- Reconnect to the gateway
        ws.close()
        ws = nil
        ready = false
        send_once = false

        print("Reconnecting to Discord Gateway")
        discord.start()
    end
end

function discord.on(event,callback)
    -- Check if there is a table in Events[event]
    if not Events[event] then
        Events[event] = {}
    end

    -- Insert the callback into the table
    table.insert(Events[event], callback)
end

function discord.invoke(event, data)
    -- Check if there is a table in Events[event]
    if not Events[event] then
        return
    end

    -- Call all callbacks
    for _,callback in pairs(Events[event]) do
        callback(data)
    end
end

function discord.start()
    if gateway then
        ws = gateway.url or "wss://gateway.discord.gg"
    else 
        ws = "wss://gateway.discord.gg"
    end

    ws = assert(http.websocket(ws .. "/?v=10&encoding=json"))

    local ws_hello = json.decode(ws.receive())
    heartbeat_interval = (ws_hello.d.heartbeat_interval / 1000) * 0.5
    sequence = ws_hello.s

    print("Connected to Discord Gateway")

    local function heartbeat()
        while ws do
            local data = {}
            data.op = 1
            data.d = sequence or textutils.json_null

            discord.ws_send(data)
            print("Heartbeat sent")
            os.sleep(heartbeat_interval)
        end
    end

    local function socketMessageReceive()
        while ws do
            local msg, err = ws.receive()
            if err or not msg then
                return
            end

            local json_data = json.decode(msg)

            if json_data.op == 11 then
                if not send_once then
                    print("Sending identify payload")
                    send_once = true

                    local data = {}
                    data.op = 2
                    data.d = {}
                    data.d.token = discord_token
                    data.d.intents = 33281
                    data.d.properties = {
                        ["os"] = "windows",
                        ["browser"] = "CC",
                        ["device"] = "CC"
                    }

                    discord.ws_send(data)
                    ready = true
                end

                -- Store the sequence number
                sequence = json_data.s or textutils.json_null
            elseif json_data.op == 0 then
                print("New event received")
                sequence = json_data.s or textutils.json_null
                discord.invoke(json_data.t, json_data.d)
            end
        end
    end

    parallel.waitForAll(heartbeat, socketMessageReceive)
end

function discord.update_presence(presence)
    if ws ~= nil then
        print("Updating presence to " .. presence)

        local data = {}
        data.op = 3
        data.d = {}
        data.d.since = textutils.json_null
        data.d.activities = {
            {
                name = presence,
                type = 0,
            },
        }
        data.d.status = "online"
        data.d.afk = false

        discord.ws_send(data)
    else
        print("Websocket not connected, unable to update presence")
    end
end

function discord.ready()
    return ready
end

return discord