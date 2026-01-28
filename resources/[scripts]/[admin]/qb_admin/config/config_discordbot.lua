Config                                      = Config or {}  -- Don't touch!
Config.DiscordBot                           = {}            -- Don't touch!
Config.DiscordBot.ConnectedMessage          = {}            -- Don't touch!

-- Discord Bot Config
-- Make sure you have created a bot and invited it to your server. 
-- It will need "Message Content Intent" enabled to function properly.
Config.DiscordBot.Enabled                   = false         -- Whether to enable or disable the Discord bot.
Config.DiscordBot.Token                     = ""            -- Your bot token.
Config.DiscordBot.Webhook                   = ""            -- Your bot webhook.
Config.DiscordBot.ChannelID                 = ""            -- The channel ID to send messages to.

Config.DiscordBot.CommandPrefix             = "!"
Config.DiscordBot.UserName                  = "919ADMIN"
Config.DiscordBot.EmbedColor                = 16711680
Config.DiscordBot.AvatarURL                 = ""
Config.DiscordBot.FooterText                = "© 2025 919ADMIN - store.nineonenine.design"
Config.DiscordBot.ChannelRefreshTick        = 1000          -- How long to wait to refresh channel messages in ms.

Config.DiscordBot.SendConnectedMessage      = true
Config.DiscordBot.ConnectedMessage.Title    = "919ADMIN Discord Bot Online"
Config.DiscordBot.ConnectedMessage.Body     = "**919ADMIN Discord Bot is now online.**\nUse the command `!cmds` to see a list of commands."

Config.DiscordBot.Commands = {                              -- List of commands that the bot will respond to. You can disable commands by setting "enabled" to false.
    {
        command = "cmds",
        enabled = true,
        description = "Get a list of available commands.",
        usage = false,
    },
    {
        command = "playercount",
        enabled = true,
        description = "Get the current player count.",
        usage = false,
    },
    {
        command = "playerlist",
        enabled = true,
        description = "Get a list of players on the server.",
        usage = false,
    },
    {
        command = "playerinfo",
        enabled = true,
        description = "Get information about a player.",
        usage = "[Player ID]",
        numargs = 1,
    },
    {
        command = "reports",
        enabled = true,
        description = "Get a list of reports.",
        usage = false,
    },
    {
        command = "reportinfo",
        enabled = true,
        description = "Get information about a report.",
        usage = "[Report ID]",
        numargs = 1,
    },
    {
        command = "reportreply",
        enabled = true,
        description = "Reply to a report.",
        usage = "[Report ID] [Message]",
        numargs = 2,
    },
    {
        command = "claimreport",
        enabled = true,
        description = "Claim a report.",
        usage = "[Report ID]",
        numargs = 1,
    },
    {
        command = "unclaimreport",
        enabled = true,
        description = "Unclaim a report.",
        usage = "[Report ID]",
        numargs = 1,
    },
    {
        command = "deletereport",
        enabled = true,
        description = "Delete a report.",
        usage = "[Report ID]",
        numargs = 1,
    },
    {
        command = "clearreports",
        enabled = true,
        description = "Clear all reports.",
        usage = false,
    },
    {
        command = "kick",
        enabled = true,
        description = "Kick a player from the server.",
        usage = "[Player ID] [Reason]",
        numargs = 2,
    },
    {
        command = "ban",
        enabled = true,
        description = "Ban a player from the server.",
        usage = "[Player ID] [Time (hours or 0 for perm)] [Reason]",
        numargs = 3,
    },
    {
        command = "warn",
        enabled = true,
        description = "Warn a player.",
        usage = "[Player ID] [Reason]",
        numargs = 2,
    },
    {
        command = "checkwarns",
        enabled = true,
        description = "Check a player's warnings.",
        usage = "[Player ID]",
        numargs = 1,
    },
    {
        command = "revive",
        enabled = true,
        description = "Revive a player.",
        usage = "[Player ID]",
        numargs = 1,
    },
    {
        command = "clothingmenu",
        enabled = true,
        description = "Open the clothing menu for a player.",
        usage = "[Player ID]",
    },
    {
        command = "clearinventory",
        enabled = true,
        description = "Clear a player's inventory.",
        usage = "[Player ID]",
        numargs = 1,
    },
    {
        command = "getinventory",
        enabled = true,
        description = "See a list of a player's inventory items.",
        usage = "[Player ID]",
        numargs = 1,
    },
    {
        command = "giveitem",
        enabled = true,
        description = "Give an item to a player.",
        usage = "[Player ID] [Item Name] [Amount]",
        numargs = 3,
    },
    {
        command = "removeitem",
        enabled = true,
        description = "Remove an item from a player.",
        usage = "[Player ID] [Item Name] [Amount]",
        numargs = 3,
    },
    {
        command = "givemoney",
        enabled = true,
        description = "Give money to a player.",
        usage = "[Player ID] [Type (cash/bank)] [Amount]",
        numargs = 3,
    },
    {
        command = "removemoney",
        enabled = true,
        description = "Remove money from a player.",
        usage = "[Player ID] [Type (cash/bank)] [Amount]",
        numargs = 3,
    },
    {
        command = "setjob",
        enabled = true,
        description = "Set a player's job.",
        usage = "[Player ID] [Job Name] [Job Grade]",
        numargs = 3,
    },
    {
        command = "setgang",
        enabled = true,
        description = "Set a player's gang.",
        usage = "[Player ID] [Gang Name] [Gang Grade]",
        numargs = 3,
    },
    {
        command = "firejob",
        enabled = true,
        description = "Fire a player from their job.",
        usage = "[Player ID]",
        numargs = 1,
    },
    {
        command = "firegang",
        enabled = true,
        description = "Kick a player from their gang.",
        usage = "[Player ID]",
        numargs = 1,
    },
    {
        command = "setweather",
        enabled = true,
        description = "Set the world weather.",
        usage = "[Weather Name]",
        numargs = 1,
    },
    {
        command = "settime",
        enabled = true,
        description = "Set the world time.",
        usage = "[Hour] [Minute]",
        numargs = 2,
    },
    {
        command = "spawncar",
        enabled = true,
        description = "Spawn a vehicle on a player.",
        usage = "[Player ID] [Vehicle Model]",
        numargs = 1,
    },
    {
        command = "savecar",
        enabled = true,
        description = "Save a player's current vehicle to their garage.",
        usage = "[Player ID]",
        numargs = 1,
    },
}