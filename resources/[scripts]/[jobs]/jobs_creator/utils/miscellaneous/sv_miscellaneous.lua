function Utils.isAllowed(playerId)
  local hasPermission
  hasPermission = IsPlayerAceAllowed(playerId, config.acePermission)
  if not hasPermission then
    hasPermission = IsPlayerAceAllowed(playerId, "jaksam")
  end
  return hasPermission
end

function notify(playerId, message)
  if playerId then
    TriggerClientEvent(Utils.eventsPrefix .. ":notifyClient", playerId, message)
  end
end

function Utils.getScriptVersion()
  return GetResourceMetadata(GetCurrentResourceName(), "version", 0)
end

function Utils.isServerEntityReady(entity)
  local timeout, currentTime
  timeout = GetGameTimer() + 3000
  while true do
    if DoesEntityExist(entity) then
      break
    end
    Citizen.Wait(100)
    currentTime = GetGameTimer()
    if timeout < currentTime then
      return false
    end
  end
  return true
end

-- Citizen.CreateThread(function()
--   local resourceName
--   resourceName = GetCurrentResourceName()
--   if resourceName == Utils.eventsPrefix then
--     if FORCE_WATERMARK then
--       SetConvarServerInfo("🏼 Jobs Creator", "By jaksam")
--     end
--   else
--     SetConvarServerInfo("🏼 Jobs Creator", "By jaksam")
--   end
-- end)

-- function sendHeartbeat()
  -- local heartbeatData
  -- if DISABLE_HEARTBEAT then
  --   return
  -- end
  -- while "scriptName" do
  --   heartbeatData = {}
  --   heartbeatData.scriptName = Utils.eventsPrefix
  --   heartbeatData.scriptVersion = Utils.getScriptVersion()
  --   PerformHttpRequest("https://nexus.jaksam-scripts.com/script-heartbeat", nil, "POST", json.encode(heartbeatData), {
  --     ["Content-Type"] = "application/json"
  --   })
  --   Citizen.Wait(300000)
  -- end
-- end

-- Citizen.CreateThread(sendHeartbeat)

function Utils.getPartialServerKey()
  -- local licenseKey, token, partialKey
  -- licenseKey = GetConvar("sv_licenseKey", GetConvar("sv_licenseKeyToken", ""))
  -- partialKey = string.sub(licenseKey, 1, 8)
  return math.random(10000000, 99999999)
end

function Utils.log(title, description, fields, webhook, color)
  local areLogsActive
  areLogsActive = config.areDiscordLogsActive
  if not areLogsActive then
    return
  end
  Utils.callModuleFunc("logs", "log", title, description, fields, webhook, color)
end
