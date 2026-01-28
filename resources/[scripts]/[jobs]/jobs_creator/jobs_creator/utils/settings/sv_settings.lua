local isConfigLoaded = false
local isFirstLoad = true

Settings = {}
Settings.serverConfig = {}
Settings.clientConfig = {}

function getResourceFilePath(fileName)
    local resourceName = GetCurrentResourceName()
    local separator = "/"
    return resourceName .. separator .. fileName
end

RegisterServerCallback(Utils.eventsPrefix .. ":getClientConfiguration", function(sourceId, callback)
    while not isConfigLoaded do
        Citizen.Wait(1000)
    end
    callback(Settings.clientConfig)
end)

function Settings.getRawConfig()
    local fileName = "current_config.json"
    local configFile = LoadResourceFile(GetCurrentResourceName(), fileName)
    
    if not configFile then
        print("Couldn't find " .. fileName)
        return nil
    end
    
    return json.decode(configFile)
end

function Settings.createConfigFileIfNotFound(defaultConfigContent)
    local fileName = "current_config.json"
    print("^2Couldn't find file '" .. fileName .. "' creating it now^7")
    
    local saved = SaveResourceFile(GetCurrentResourceName(), fileName, defaultConfigContent, #defaultConfigContent)
    if saved then
        return true
    end
    
    local currentConfigPath = getResourceFilePath(fileName)
    local defaultConfigPath = getResourceFilePath("utils/settings/default_config.json")
    local errorMessage = "^1Couldn't create '" .. currentConfigPath .. "' file automatically^7"
    
    Utils.showPermanentError(
        errorMessage,
        "^3Please create it manually by duplicating '" .. defaultConfigPath .. "'' and rename the copy of it to '" .. currentConfigPath .. "', then restart the script when done^7"
    )
    
    return false
end

function Settings.loadConfig()
    local resource = GetCurrentResourceName()
    local currentConfigFile = LoadResourceFile(resource, "current_config.json")
    local defaultConfigFile = LoadResourceFile(resource, "utils/settings/default_config.json")
    
    if not defaultConfigFile then
        Utils.showPermanentError(
            "^1Couldn't find '" .. getResourceFilePath("utils/settings/default_config.json") .. "'^7",
            "^3Please check that the file exists and the name is correct^7"
        )
        return false
    end
    
    if not currentConfigFile then
        if not Settings.createConfigFileIfNotFound(defaultConfigFile) then
            return false
        end
        return Settings.loadConfig()
    end

    local currentConfig = json.decode(currentConfigFile)
    local defaultConfig = json.decode(defaultConfigFile)
    local mergedShared = Utils.useDefaultValues(currentConfig.shared, defaultConfig.shared)

    print(json.encode(mergedShared, {indent = true}))

    Settings.serverConfig = Utils.useDefaultValues(
        Utils.useDefaultValues(currentConfig.server, defaultConfig.server),
        mergedShared
    )
    
    Settings.clientConfig = Utils.useDefaultValues(
        Utils.useDefaultValues(currentConfig.client, defaultConfig.client),
        mergedShared
    )

    isConfigLoaded = true
    config = Settings.serverConfig

    if isFirstLoad then
        isFirstLoad = false
        TriggerEvent(Utils.eventsPrefix .. ":serverConfigLoadedOnStart")
    end
    
    TriggerEvent(Utils.eventsPrefix .. ":serverConfigLoaded")
    return true
end

function Settings.mergeConfigTables(oldConfig, newConfig)
    local merged = {}
    
    for key, value in pairs(oldConfig) do
        merged[key] = value
    end
    
    for key, value in pairs(newConfig) do
        merged[key] = value
    end
    
    return merged
end

function Settings.updateSettings(serverSettings, sharedSettings, clientSettings)
    local rawConfig = Settings.getRawConfig()
    if not rawConfig then
        print("^1Could not load current config file^7")
        return false
    end
    
    local mergedConfig = {
        server = Settings.mergeConfigTables(rawConfig.server or {}, serverSettings or {}),
        shared = Settings.mergeConfigTables(rawConfig.shared or {}, sharedSettings or {}),
        client = Settings.mergeConfigTables(rawConfig.client or {}, clientSettings or {})
    }
    
    local configJson = json.encode(mergedConfig)
    local fileName = "current_config.json"
    
    if not SaveResourceFile(GetCurrentResourceName(), fileName, configJson, #configJson) then
        print("\n======================")
        print("^1Couldn't update settings, impossible to write the file '" .. GetCurrentResourceName() .. "/" .. fileName .. "'^7")
        print("^3Please check if the file is not read-only. Note: The issue is NOT caused by this script, but it's caused by your server/host^7")
        print("^7======================\n")
        error("Read server console")
        return false
    end

    local defaultConfigFile = LoadResourceFile(GetCurrentResourceName(), "utils/settings/default_config.json")
    if not defaultConfigFile then
        print("^1Couldn't find default config file^7")
        return false
    end
    
    local defaultConfig = json.decode(defaultConfigFile)
    local mergedShared = Utils.useDefaultValues(mergedConfig.shared, defaultConfig.shared)
    
    Settings.serverConfig = Utils.useDefaultValues(
        Utils.useDefaultValues(mergedConfig.server, defaultConfig.server),
        mergedShared
    )
    
    Settings.clientConfig = Utils.useDefaultValues(
        Utils.useDefaultValues(mergedConfig.client, defaultConfig.client),
        mergedShared
    )
    
    config = Settings.serverConfig
    TriggerEvent(Utils.eventsPrefix .. ":serverConfigLoaded")
    TriggerClientEvent(Utils.eventsPrefix .. ":updateClientSettings", -1)
    return true
end

RegisterServerCallback(Utils.eventsPrefix .. ":updateSettings", function(sourceId, callback, serverSettings, sharedSettings, clientSettings)
    if not Utils.isAllowed(sourceId) then
        callback(false)
        return
    end
    
    local success, errorMessage = pcall(Settings.updateSettings, serverSettings, sharedSettings, clientSettings)
    if success then
        callback(true)
    else
        callback(errorMessage)
    end
end)

function Settings.getFullConfig()
    local fullConfig = {}
    
    for key, value in pairs(Settings.serverConfig) do
        fullConfig[key] = value
    end
    
    for key, value in pairs(Settings.clientConfig) do
        fullConfig[key] = value
    end
    
    return fullConfig
end

RegisterServerCallback(Utils.eventsPrefix .. ":getDefaultConfiguration", function(sourceId, callback)
    if not Utils.isAllowed(sourceId) then
        callback(false)
        return
    end
    
    local defaultConfigFile = LoadResourceFile(GetCurrentResourceName(), "utils/settings/default_config.json")
    if not defaultConfigFile then
        print("^1Couldn't find '" .. "utils/settings/default_config.json" .. "'^7")
        callback(false)
        return
    end
    
    local defaultConfig = json.decode(defaultConfigFile)
    local flatConfig = {}
    
    for sectionKey, sectionValue in pairs(defaultConfig) do
        for key, value in pairs(sectionValue) do
            flatConfig[key] = value
        end
    end
    
    callback(flatConfig)
end)
