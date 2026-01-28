-- 919ADMIN Classic Admin Panel Permissions
-- Here is where you can assign permissions to players based on their license
-- as well as add permission groups and set what they have access to.
Config.PermissionedUsers = {
    -- Get licenses from txAdmin by clicking on the user and then navigating to "IDs" tab.
    -- Make sure to take the one that is prefixed with "license:"
    -- "license2:", "fivem:", "live:" etc are not valid.
    -- ["LICENSE"] = "god",
    -- ["license:245657daecaba7543bca2544351ea382c713434f1"] = "god",
}

-- Discord Roles
-- Here is where you can enable the discord roles feature and set the bot token, guild id, and role ids.
Config.DiscordRoles = {
    Enabled = false,

    -- This is your discord server ID, to get the server id, make sure you have Discord in developer mode, and right click the server, and click "Copy ID".
    GuildID = "DISCORD_SERVER_ID",

    -- SET THE BOT TOKEN IN config_server.lua

    -- Here you can set which discord roles map to which permission groups.
    -- Make sure the value (ie. "god") matches permission groups that exist in Config.Permissions below.
    -- To get the role ids, make sure you have Discord in developer mode, and right click the role, and click "Copy ID".
    Roles = {
        ["ROLE_ID"] = "god",
    }
}

-- Role Priority System
-- When a player has multiple Discord roles, the system will use the role with the highest priority
-- This is also used to determine inheritance of permissions.
-- Higher numbers = higher priority (god > admin > mod)
Config.RolePriority = {
    ["god"] = 100,
    ["admin"] = 50,
    ["mod"] = 10,
    -- Add custom roles here with their priority values
    -- ["custom_role"] = 75,
}

Config.RoleColors = { -- The colors for the different roles in the admin panel's player list. You can use hex codes or predefined css colors.
    ["god"] = "OrangeRed",
    ["admin"] = "Orange",
    ["mod"] = "CornflowerBlue",
}

Config.Permissions = {
    ["god"] = {
        AllowedActions = {
            -- Exclusive High-Level Pages
            "resourcepage", -- Access the Resource control page
            "servermetrics", -- Access the server metrics page

            --------------------------------- Server Actions Group ---------------------------------
            "reviveall", -- Revive all players
            "messageall", -- Message all players
            "setweather", -- Change the server weather
            "settime", -- Change the server time

            --------------------------------- Developer Actions Group ---------------------------------
            "vec3", -- Get vector3 position
            "vec4", -- Get vector4 position
            "heading", -- Get your heading
            "loadipl", -- Load an IPL (map section)
            "unloadipl", -- Unload an IPL (map section)
            "setViewDistance", -- Set view distance
            "copyEntityInfo", -- Copy entity information
            "freeaimMode", -- Enable free aim mode
            "displayVehicles", -- Display vehicle dev mode
            "displayPeds", -- Display peds dev mode
            "displayObjects", -- Display objects dev mode

            --------------------------------- Mass Entity Actions Group ---------------------------------
            "massdv", -- Delete all spawned vehicles, even population ones
            "massdp", -- Delete all peds, even population ones

            --------------------------------- Management Actions Group ---------------------------------
            "clearreports", -- Clear reports
            "clearadminchat", -- Clear adminchat
            "clearlogs", -- Clear logslist

            --------------------------------- Highest Level Player Actions ---------------------------------
            "kill", -- Kill yourself, others
            "ban", -- Ban a player from the server
            "unban", -- Unban a player
        },
    },
    ["admin"] = {
        AllowedActions = {
            -- Page Permissions
            "characterspage", -- Access the All Characters page
            "serverlogs", -- Access the server logs page
            "jobpage", -- Access the jobs page
            "gangpage", -- Access the gangs page
            "banspage", -- Access the bans page
            "vehiclesinfo", -- Access the vehicle spawn code list page
            "leaderboardinfo", -- Check the leaderboards
            "mapinfo", -- Access the map page

            -- Advanced Report Management
            "deletereport", -- Delete a report
            "deletecharacter", -- Delete a character

            --------------------------------- Self Actions Group ---------------------------------
            "revives", -- Revive yourself
            "feeds", -- Feed yourself
            "uncuffSelf", -- Uncuff yourself
            "sclothing", -- Give yourself the skin menu
            "invisibility", -- Toggle invisibility
            "playerblips", -- Toggles player blips on the map
            "fastrun", -- Toggles fast run
            "godmode", -- Toggles godmode
            "forceradar", -- Force minimap on
            "superjump", -- Toggles super jump
            "noragdoll", -- Toggles ragdoll
            "infinitestam", -- Toggles infinite stamina
            "clearblood", -- Clears your ped of blood and visual damage
            "wetclothes", -- Makes your clothes wet
            "dryclothes", -- Dries off your clothes

            --------------------------------- Vehicle Actions Group ---------------------------------
            "repairvehicle", -- Repair a vehicle
            "fillgastank", -- Fills the gas tank of the vehicle you're in
            "washvehicle", -- Washes the vehicle you're in
            "maxperformanceupgrades", -- Max performance upgrades (vehicle)
            "randomvisualparts", -- Random visual parts (vehicle)
            "setcolor", -- Set color (vehicle)
            "setlivery", -- Set livery (vehicle)
            "setmedriver", -- Teleport into nearest vehicle as driver
            "setmepassenger", -- Teleport into nearest vehicle as passenger
            "lockvehicle", -- Lock a vehicle
            "unlockvehicle", -- Unlock a vehicle

            --------------------------------- Entity Actions Group ---------------------------------
            "spawncar", -- Spawn a vehicle
            "deleteclosestvehicle", -- Delete closest vehicle
            "deleteclosestped", -- Delete closest ped
            "deleteclosestobject", -- Delete closest object

            --------------------------------- Player Actions Group ---------------------------------
            "revive", -- Revive a player
            "foodandwater", -- Feed a player
            "relievestress", -- Relieve stress of a player
            "repairplayervehicle", -- Repair a player's vehicle
            "setpedmodel", -- Set a player's ped model
            "clothing", -- Give a player the skin menu
            "savecar", -- Add a player's current vehicle to their garage
            "savedata", -- Save player data
            "sendback", -- Send a player back to their location (requires teleport permission)
            "sendto", -- Send a player to a location (requires teleport permission)
            "givetakemoney", -- Give or take money from a player
            "givecash", -- Give cash to a player (requires givetakemoney permission)
            "removecash", -- Remove cash from a player (requires givetakemoney permission)
            "givebank", -- Give bank money to a player (requires givetakemoney permission)
            "removebank", -- Remove bank money from a player (requires givetakemoney permission)
            "setjob", -- Set job of a player
            "firejob", -- Fire a player from their job
            "setgang", -- Set gang of a player
            "firegang", -- Fire a player from their gang
            "openinventory", -- Open a player's inventory
            "clearinventory", -- Clear inventory
            "cuff", -- Cuff/uncuff a player
            "freeze", -- Freeze a player
            "kick", -- Kick a player from the server
            "checkwarns", -- Check the warnings of a player
            "warn", -- Warn a player
        },
    },
    ["mod"] = {
        AllowedActions = {
            "adminmenu", -- Open the admin menu
            "adminchat", -- Access the admin chat
            "itemsinfo", -- Access the item spawn code list page

            -- Basic Report Management
            "viewreports", -- Access the reports list
            "claimreport", -- Claim a report

            -- Basic Self Actions
            "goback", -- Teleport back
            "tpm", -- Teleport to marker
            "playernames", -- Toggle player names
            "noclip", -- Noclip

            -- Basic Player Actions
            "spectate", -- Spectate a player
            "teleport", -- Teleport yourself, others, to location
            "bring", -- Bring a player to you (requires teleport permission)
            "giveitem", -- Give a player an item, or several thousand
            "screenshot", -- Screenshot a player
        },
    }
}

-- If you want to use ace permissions instead of the default, set this to true.
-- No support will be given if you use ace permissions. We will not help you set it up.
Config.UseAcePermissions = false