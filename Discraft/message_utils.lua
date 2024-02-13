local json = require ('Discraft/json_utils')
local discord = require("Discraft/discord_utils")
local colors = require("Discraft/color_utils")

local message = {}

-- Connect chatbox
local chatbox = peripheral.find("chatBox")

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

function message.send(msg)
    -- Pause for a moment to avoid chatbox spam
    sleep(1)

    -- local formatted_msg = {{ text = msg }}

    -- chatbox.sendFormattedMessage(json.encode(formatted_msg), "Dev", "&4&l" .. message_name, "<>", "&c&l")
    chatbox.sendMessage(msg, message_name, "[]")
end

function message.event()
    print("Listening for chat events...")

    while true do
        local event, username, msg, uuid, isHidden = os.pullEvent("chat")

        -- Send message to Discord
        local discord_message = username .. ": " .. msg
        discord.send_embed("In-Game Message", discord_message)
    end
end

return message