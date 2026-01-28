local moduleType = "notify" -- Module category
local moduleName = "example" -- THIS module name

-- Don't touch, required to appear in in-game settings
Integrations.modules = Integrations.modules or {}
Integrations.modules[moduleType] = Integrations.modules[moduleType] or {}
Integrations[moduleType] = Integrations[moduleType] or {}
Integrations[moduleType][moduleName] = {}
table.insert(Integrations.modules[moduleType], moduleName)

Integrations[moduleType][moduleName].showNotification = function(message, coloredMessage)
    -- ADD YOUR EXPORT HERE, THIS IS JUST AN EXAMPLE
    exports["notification_script"]:notify(message)
end
