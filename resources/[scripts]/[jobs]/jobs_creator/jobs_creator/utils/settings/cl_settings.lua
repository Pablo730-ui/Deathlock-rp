local isFirstLoad
Settings = {}
Settings.clientConfig = {}
isFirstLoad = true
function Settings.loadConfig()
  local clientConfig, eventName, eventPrefix
  clientConfig = TriggerServerPromise(Utils.eventsPrefix .. ":getClientConfiguration")
  Settings.clientConfig = clientConfig
  config = Settings.clientConfig
  print("Configuration loaded")
  if isFirstLoad then
    isFirstLoad = false
    TriggerEvent(Utils.eventsPrefix .. ":clientConfigLoadedOnStart")
  end
  TriggerEvent(Utils.eventsPrefix .. ":clientConfigLoaded")
  return true
end
RegisterNetEvent(Utils.eventsPrefix .. ":updateClientSettings", Settings.loadConfig)
RegisterNUICallback("saveSettings", function(data, callback)
  local result, serverSettings, sharedSettings, clientSettings
  serverSettings = data.serverSettings
  sharedSettings = data.sharedSettings
  clientSettings = data.clientSettings
  result = TriggerServerPromise(Utils.eventsPrefix .. ":updateSettings", serverSettings, sharedSettings, clientSettings)
  callback(result)
end)
RegisterNUICallback("getDefaultConfiguration", function(data, callback)
  local defaultConfig
  defaultConfig = TriggerServerPromise(Utils.eventsPrefix .. ":getDefaultConfiguration")
  callback(defaultConfig)
end)
