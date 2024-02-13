local discord_success, discord = pcall(require, "Discraft/discord_utils")
local colors_success, colors = pcall(require, "Discraft/color_utils")
local message_success, message = pcall(require, "Discraft/message_utils")

if not discord_success then
    discord = nil
end

if not colors_success then
    colors = nil
end

if not message_success then
    message = nil
end

-- Script id for installation
local raw_github = "https://raw.githubusercontent.com/ColdUnwanted/Discraft/master/"
local main_script = raw_github .. "main.lua"
local discord_script = raw_github .. "Discraft/discord_utils.lua"
local color_script = raw_github .. "Discraft/color_utils.lua"
local json_script = raw_github .. "Discraft/json_utils.lua"
local message_script = raw_github .. "Discraft/message_utils.lua"

-- Initial install of script
if not discord_success and not colors_success and not message_success then
    print("Initializing Discraft...")

    -- Check if it's first time install
    local has_existing_install = fs.exists("startup.lua")

    -- Remove exisiting version
    if has_existing_install then
        fs.delete("startup.lua")
    end

    -- Download the latest version of the script
    shell.run("wget", main_script, "startup.lua")
    shell.run("wget", discord_script, "Discraft/discord_utils.lua")
    shell.run("wget", color_script, "Discraft/color_utils.lua")
    shell.run("wget", json_script, "Discraft/json_utils.lua")
    shell.run("wget", message_script, "Discraft/message_utils.lua")

    if not has_existing_install and not fs.exists("config.json") then
        print("Opening config file for editing...")

        sleep(2.5)
        shell.run("edit", "config.json")
    end

    -- Reboot the computer
    print("Install complete, rebooting...")
    sleep(2.5)
    os.reboot()
end

-- Delay startup of computer by 5 seconds
sleep(5)

-- Check if discord connection can be established
if not discord.check_connection() then
    error("Failed to connect to Discord, please check your bot token or channel id again.")
    return
end

-- 

-- On ready event
discord.on("READY", function(data)
    -- Send a message to the channel
    discord.send_embed("Discraft", "Bot is online and ready to go!", colors.green())
end)

-- On message event
discord.on("MESSAGE_CREATE", function(msg)
    -- Send message to in-game chat
    message.send(msg)
end)

discord.start()