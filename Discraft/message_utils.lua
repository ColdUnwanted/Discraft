local json = require ('Discraft/json_utils')
local discord = require("Discraft/discord_utils")
local colors = require("Discraft/color_utils")

local message = {}

-- Connect chatbox
local chatbox = peripheral.find("chatbox")

if not chatbox then
    error("No chatbox found on any side of the computer!")
    return
end

-- Fetch configuration
local message_name = "Discraft"
if fs.exists('config.json') then
    print('Loading settings from config file...')

    local config_file = fs.open('config.json', 'r')
    local config = json.decode(config_file.readAll())
    config_file.close()

    if config.message_name then
        message_name = config.message_name
    else
        error('Config file is missing message_name')
    end
else
    error('Config file not found')
end

function message.send(message)
    -- Pause for a moment to avoid chatbox spam
    sleep(1)

    chatbox.sendMessage(message, message_name, "<>", "&b")
end

function message.event()
    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")

        -- Send message to Discord
        local discord_message = username .. ": " .. message
        discord.send_embed("Discord Message", discord_message)
    end
end

return message