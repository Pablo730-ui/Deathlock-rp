Config = Config or {}

-- 919DESIGN Classic Admin Panel Config
-- Thank you for purchasing the 919ADMIN Classic Admin Panel!
-- If you have any questions, please contact us on Discord: https://discord.gg/Xv7faqUXUf

-- Framework Config
-- Set the framework you are using
-- Valid Values: "autodetect" or "qbcore" or "qbox" or "esx"  
Config.Framework                            = "autodetect"

-- Inventory Config
-- Set the inventory you are using
-- Valid Values: "autodetect" or "ox_inventory" or "qs-inventory" or "ps-inventory" or "lj-inventory" or "codem-inventory" or "core_inventory"
Config.Inventory                            = "autodetect"

-- Set the keys you want to use to open the admin panel, noclip, and toggle player names
-- Please note that changing this once the key has been set once will not change it for existing players
-- You will need to change the key in your pause menu, game settings, under controls -> FiveM
Config.AdminPanelKey                        = "PAGEDOWN"                -- The default key to open the admin panel
Config.NoClipKey                            = "INSERT"                  -- The default key to start noclip
Config.ShowNamesKey                         = "PAGEUP"                      -- The default key to toggle player names

-- Enable the admin panel command
-- If you would like to use another command, you can change it here (AdminPanelCommand)
-- If you would like to not have a command and just use the key, set EnableAdminPanelCommand to false
Config.EnableAdminPanelCommand              = true                      -- Whether to enable the admin panel command (/a by default)
Config.AdminPanelCommand                    = "a"

-- Whether or not to show the IP in the identifiers box in player info view
Config.ShowIPInIdentifiers                  = false

-- Report Config
-- Enable or disable the report command if you use another report system (reports tab will still show)
Config.EnableReportCommand                  = true

-- The command to use for reports (default /report)
Config.ReportCommand                        = "report"

-- The maximum amount of reports a player can place
Config.MaxReportsPerPlayer                  = 2

-- Whether to save reports, adminchat, and logs to JSON onResourceStopped (server restarts etc) and load from JSON on resource start
Config.SaveTOJSON                           = true

-- Whether or not to show the red warning screen when a player is warned.
Config.ShowWarningScreen                    = true

-- Teleport Locations
-- The locations that are listed in the "send to" menu, and on the dashboard for yourself to go to.
Config.TeleportLocations                    = {
    { id = "pillbox", label = "Pillbox", coords = vector3(299.01, -577.48, 43.26) },
    { id = "legion", label = "Legion Square", coords = vector3(215.75, -804.26, 30.81) },
    { id = "lsc", label = "LS Customs", coords = vector3(-366.58, -126.01, 38.69) },
    { id = "mrpd", label = "MRPD", coords = vector3(415.41, -993.4, 29.38) },
}

-- ADVANCED CONFIGURATION
-- Please only adjust these if you have been asked to do so by 919DESIGN support.
-- The amount of time the leaderboard cache should be updated (in milliseconds, default = 60 minutes)
Config.LeaderboardCacheTimer                = 60000 * 60

-- The amount of time the player graph should update (in milliseconds, default = 5 mins)
Config.PlayerGraphFrequency                 = 300000

-- The bitrate for large events (like the player list, default = 0.2mbps / 200kbps / 200,000bps)
Config.LargeEventDataBitrate                = 200000

-- How long the main characters cache should last (in milliseconds, default = 5 minutes)
Config.CharactersCacheExpiry                = 300000

-- How long the server metrics cache should last (in milliseconds, default = 5 minutes)
Config.ServerMetricsCacheExpiry             = 300000

-- Whether to enable debug prints or not
Config.EnableDebug                          = false