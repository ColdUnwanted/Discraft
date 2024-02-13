local discord = require("Discraft/discord_utils")
local colors = require("Discraft/color_utils")

local player = {}

-- Connect player detector
local playerDetector = peripheral.find("playerDetector")

if not playerDetector then
    error("Player detector not found")
    return
end

function player.get_player_count()
    local players = playerDetector.getOnlinePlayers()

    -- Count players
    local count = 0
    for _ in pairs(players) do count = count + 1 end

    return count
end

function player.join_event()
    while true do
        local event, username, dimension = os.pullEvent("playerJoin")

        -- Send event to discord
        discord.send_embed("Player Join Event", "Player **" .. username .. "** joined the server", colors.green)

        -- Update player count in presence
        discord.update_presence("with " .. player.get_player_count() .. " players")
    end
end

function player.leave_event()
    while true do
        local event, username, dimension = os.pullEvent("playerLeave")

        -- Send event to discord
        discord.send_embed("Player Leave Event", "Player **" .. username .. "** left the server", colors.red)

        -- Update player count in presence
        discord.update_presence("with " .. player.get_player_count() .. " players")
    end
end

function player.initial_set_presence()
    -- Wait for discord to be ready
    while not discord.ready do
        os.sleep(1)
    end
    print(discord.ready)
    -- Set initial presence
    discord.update_presence("with " .. player.get_player_count() .. " players")
end

function player.event()
    parallel.waitForAll(player.join_event, player.leave_event, player.initial_set_presence)
end

return player