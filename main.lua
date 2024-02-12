local discord = require("Discraft/discord_utils")
local colors = require("Discraft/color_utils")

-- Script id for installation
-- TODO

-- Initial install of script
if arg[1] == "install" then
    print("Initializing Discraft...")

    -- Check if it's first time install
    local has_existing_install = fs.exists("startup.lua")

    -- Remove exisiting version
    if has_existing_install then
        fs.delete("startup.lua")
    end

    -- Download the latest version of the script
    -- TODO

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

print(discord.check_connection())
print(discord.send_embed("test", "test", colors.green()))

discord.on("READY", function(data)
    print("Bot is ready!!!")
end)

discord.on("MESSAGE_CREATE", function(msg)
    print(msg.author.username .. ": " .. msg.content)
end)

discord.start()