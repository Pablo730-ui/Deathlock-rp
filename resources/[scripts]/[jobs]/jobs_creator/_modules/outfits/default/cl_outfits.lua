local moduleType = "outfits" -- Module category
local moduleName = "default" -- THIS module name

-- Don't touch, required to appear in in-game settings
Integrations.modules = Integrations.modules or {}
Integrations.modules[moduleType] = Integrations.modules[moduleType] or {}
Integrations[moduleType] = Integrations[moduleType] or {}
Integrations[moduleType][moduleName] = {}
table.insert(Integrations.modules[moduleType], moduleName)

--[[
    Nothing to edit, the code is internal
]]

-- This function has to return true if you want to use external menu, false to use Jobs Creator menu
Integrations[moduleType][moduleName].openExternalMenu = function()
    return false
end
