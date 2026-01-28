fx_version 'cerulean'
game 'gta5'

author 'amazonium.' -- aka Sinatra
description '919DESIGN Admin Panel'
version '1.14.3 LTS'
lua54 'yes'

ui_page 'html/index.html'

files {
    'html/**'
}

shared_scripts {
    'locales/locale.lua',
    'locales/en.lua',
    'config/config_main.lua',
    'config/config_integrations.lua',
    'config/config_permissions.lua',
    'bridge/qbcore.lua',
    'bridge/esx.lua',
    'bridge/qbox.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/config_server.lua',
    'config/config_discordbot.lua',

    'server/core/init.lua',
    'server/utils/utils.lua',
    'server/permissions/permissions.lua',
    'server/discord/discordroles.lua',
    'server/discord/discord_bot_locked.lua',
    'server/discord/discord_bot.lua',
    'server/callbacks/callbacks.lua',
    'server/events/panel.lua',
    'server/events/data.lua',
    'server/events/reports.lua',
    'server/actions/player.lua',
    'server/actions/punishments.lua',
    'server/actions/server.lua',
    'server/actions/items.lua',
    
}

client_scripts {
    -- Core initialization
    'client/core/init.lua',
    
    -- Utility functions
    'client/utils/misc.lua',
    'client/utils/entity.lua', 
    'client/utils/player.lua',
    
    -- Core functionality
    'client/core/commands.lua',
    
    -- Event handlers
    'client/events/alerts.lua',
    'client/events/menu.lua',
    'client/events/data.lua',
    
    -- Features
    'client/features/noclip.lua',
    
    -- FreeCam functionality
    'client/freecam/utils.lua',
    'client/freecam/config.lua',
    'client/freecam/camera.lua',
    'client/freecam/main.lua',
    
    -- NUI callbacks
    'client/nui/menu.lua',
    'client/nui/data.lua',
    'client/nui/reports.lua',
    'client/nui/admin.lua',
    'client/nui/actions.lua',
    
    -- Player actions
    'client/actions/entities.lua',
    'client/actions/player.lua',
    'client/actions/vehicle.lua',
    
    'client/debug/devmode.lua',
}

escrow_ignore {
    -- config/Configuration Files
    'config/config_main.lua',
    'config/config_server.lua',
    'config/config_integrations.lua',
    'config/config_discordbot.lua',
    'config/config_permissions.lua',

    -- Server Files
    'server/core/init.lua',
    'server/utils/utils.lua',
    'server/permissions/permissions.lua',
    'server/discord/discordroles.lua',
    'server/discord/discord_bot.lua',
    'server/callbacks/callbacks.lua',
    'server/events/panel.lua',
    'server/events/data.lua',
    'server/events/reports.lua',
    'server/actions/player.lua',
    'server/actions/punishments.lua',
    'server/actions/server.lua',
    'server/actions/items.lua',

    -- Compatibility Stuff
    'bridge/qbcore.lua',
    'bridge/esx.lua',
    'bridge/qbox.lua',

    -- NoClip Stuff
    'client/freecam/utils.lua',
    'client/freecam/config.lua',
    'client/freecam/camera.lua',
    'client/freecam/main.lua',
    'client/features/noclip.lua',

    -- Locale Stuff
    'locales/locale.lua',
    'locales/en.lua',
}

dependencies { 'oxmysql' } 
dependency '/assetpacks'