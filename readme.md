# Discraft
A CC:Tweaked project built with the intent of interacting with Minecraft server via Discord.<br/>
It is built upon the usage of Discord API library and Discord Gateway websocket.

## Installation
1. Make sure you have a computer, [Chat Box](https://docs.advanced-peripherals.de/peripherals/chat_box/) and [Player Detector](https://docs.advanced-peripherals.de/peripherals/player_detector/). 
2. Place the computer with the `Chat Box` and `Player Detector` on its sides.
3. Run `wget run https://raw.githubusercontent.com/ColdUnwanted/Discraft/master/main.lua` to handle the rest.

### Initial Setup
A config file will be generated with some fields
* `bot_token` - Discord bot [token](https://www.writebots.com/discord-bot-token/)
* `channel_id` - Guild's channel id to send message to, make sure send permission is given to the bot
* `message_name` - The message username to show when sending message to in-game
