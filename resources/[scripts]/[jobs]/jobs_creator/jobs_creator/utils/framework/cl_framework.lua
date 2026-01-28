local currentFramework
currentFramework = CURRENT_FRAMEWORK
function Framework.getPlayerJob()
  local playerData, waitTime
  if "ESX" == currentFramework then
    while true do
      playerData = ESX.GetPlayerData()
      if nil ~= playerData.job then
        break
      end
      Citizen.Wait(500)
    end
    playerData = ESX.GetPlayerData()
    return playerData.job.name
  elseif "QB-core" == currentFramework then
    while true do
      playerData = QBCore.Functions.GetPlayerData()
      if nil ~= playerData.job then
        break
      end
      Citizen.Wait(500)
    end
    playerData = QBCore.Functions.GetPlayerData()
    return playerData.job.name
  end
end
function Framework.getPlayerJobGrade()
  local playerData
  if "ESX" == currentFramework then
    while true do
      playerData = ESX.GetPlayerData()
      if nil ~= playerData.job then
        break
      end
      Citizen.Wait(500)
    end
    playerData = ESX.GetPlayerData()
    return playerData.job.grade
  elseif "QB-core" == currentFramework then
    while true do
      playerData = QBCore.Functions.GetPlayerData()
      if nil ~= playerData.job then
        break
      end
      Citizen.Wait(500)
    end
    playerData = QBCore.Functions.GetPlayerData()
    return playerData.job.grade.level
  end
end
function Framework.getPlayerJobLabel()
  local playerData
  if "ESX" == currentFramework then
    while true do
      playerData = ESX.GetPlayerData()
      if nil ~= playerData.job then
        break
      end
      Citizen.Wait(500)
    end
    playerData = ESX.GetPlayerData()
    return playerData.job.label
  elseif "QB-core" == currentFramework then
    while true do
      playerData = QBCore.Functions.GetPlayerData()
      if nil ~= playerData.job then
        break
      end
      Citizen.Wait(500)
    end
    playerData = QBCore.Functions.GetPlayerData()
    return playerData.job.label
  end
end
function Framework.showHelpNotification(text)
  local entryKey
  entryKey = Utils.eventsPrefix .. "_frameworkHelpNotification"
  AddTextEntry(entryKey, text)
  DisplayHelpTextThisFrame(entryKey, false)
end
function Framework.showNotification(text, notifyData)
  if "ESX" == currentFramework then
    ESX.ShowNotification(text)
  elseif "QB-core" == currentFramework then
    QBCore.Functions.Notify(notifyData)
  end
end
function Framework.getClosestPed()
  local getClosestPedFunc = nil
  if "ESX" == currentFramework then
    getClosestPedFunc = ESX.Game.GetClosestPed
  elseif "QB-core" == currentFramework then
    getClosestPedFunc = QBCore.Functions.GetClosestPed
  end
  if not getClosestPedFunc then
    print("^2Cannot find 'getClosestPedFunction' function^7")
    return
  end
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)
  local closestPed, distance = getClosestPedFunc(playerCoords)
  if closestPed == playerPed then
    local excludePeds = {playerPed}
    closestPed, distance = getClosestPedFunc(playerCoords, excludePeds)
  end
  return closestPed, distance
end
function Framework.getClosestPlayer(returnServerId, maxDistance)
  local getClosestPlayerFunc = nil
  if "ESX" == currentFramework then
    getClosestPlayerFunc = ESX.Game.GetClosestPlayer
  elseif "QB-core" == currentFramework then
    getClosestPlayerFunc = QBCore.Functions.GetClosestPlayer
  end
  if not getClosestPlayerFunc then
    print("^2Cannot find 'getClosestPlayerFunction' function^7")
    return
  end
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)
  local closestPlayerId, distance = getClosestPlayerFunc(playerCoords)
  local currentPlayerId = PlayerId()
  if closestPlayerId == currentPlayerId then
    closestPlayerId, distance = getClosestPlayerFunc()
  end
  if closestPlayerId then
    if closestPlayerId ~= currentPlayerId and -1 ~= closestPlayerId and (not maxDistance or maxDistance >= distance) then
      if returnServerId then
        return GetPlayerServerId(closestPlayerId)
      else
        return closestPlayerId
      end
    end
  else
    return nil
  end
end
function Framework.draw3dText(coords, text, scale, font)
  local position, camCoords, distance, textScale, fovMultiplier
  position = vector3(coords.x, coords.y, coords.z)
  camCoords = GetGameplayCamCoords()
  distance = #(position - camCoords)
  if not scale then
    scale = 1
  end
  if not font then
    font = 0
  end
  textScale = scale / distance
  textScale = textScale * 2
  fovMultiplier = 1 / GetGameplayCamFov()
  fovMultiplier = fovMultiplier * 100
  textScale = textScale * fovMultiplier
  SetTextScale(0.0 * textScale, 0.55 * textScale)
  SetTextFont(font)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(true)
  SetDrawOrigin(position, 0)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.0, 0.0)
  ClearDrawOrigin()
end
function Framework.deleteVehicle(vehicle)
  if "ESX" == currentFramework then
    ESX.Game.DeleteVehicle(vehicle)
  elseif "QB-core" == currentFramework then
    QBCore.Functions.DeleteVehicle(vehicle)
  end
end
RegisterNetEvent(Utils.eventsPrefix .. ":framework:deleteVehicle", function(netId)
  local vehicle
  if not NetworkDoesNetworkIdExist(netId) then
    return
  end
  vehicle = NetToVeh(netId)
  Framework.deleteVehicle(vehicle)
end)
function Framework.setVehicleProperties(vehicle, properties)
  if not properties then
    return
  end
  if "ESX" == currentFramework then
    ESX.Game.SetVehicleProperties(vehicle, properties)
  elseif "QB-core" == currentFramework then
    QBCore.Functions.SetVehicleProperties(vehicle, properties)
  end
end
function Framework.getVehicleProperties(vehicle)
  if "ESX" == currentFramework then
    return ESX.Game.GetVehicleProperties(vehicle)
  elseif "QB-core" == currentFramework then
    return QBCore.Functions.GetVehicleProperties(vehicle)
  end
end
function Framework.getClosestVehicle(maxDistance)
  local closestVehicle, distance
  closestVehicle = nil
  distance = nil
  if "ESX" == currentFramework then
    closestVehicle, distance = ESX.Game.GetClosestVehicle()
  elseif "QB-core" == currentFramework then
    closestVehicle, distance = QBCore.Functions.GetClosestVehicle()
  end
  if closestVehicle and maxDistance >= distance then
    return closestVehicle, distance
  else
    return nil
  end
end
function Framework.getPlayerSkin()
  local skinPromise, framework
  if "default" ~= config.modules.outfits then
    return Utils.callModuleFunc("outfits", "getPlayerClothes")
  end
  skinPromise = promise.new()
  framework = Framework.getFramework()
  if "ESX" == framework then
    TriggerEvent("skinchanger:getSkin", function(skin)
      skinPromise:resolve(skin)
    end)
  elseif "QB-core" == framework then
    TriggerEvent("qb-clothes:getPlayerSkin", function(skin)
      skinPromise:resolve(skin)
    end)
  end
  return Citizen.Await(skinPromise)
end
function Framework.getClosePlayers(maxDistance, returnServerIds)
  if not maxDistance then
    maxDistance = 10.0
  end
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)
  local closePlayers = {}
  for ped in pairs(GetGamePool("CPed")) do
    if IsPedAPlayer(ped) then
      if ped ~= playerPed then
        local pedCoords = GetEntityCoords(ped)
        local distance = #(pedCoords - playerCoords)
        if maxDistance >= distance then
          if returnServerIds then
            local playerIndex = NetworkGetPlayerIndexFromPed(ped)
            table.insert(closePlayers, GetPlayerServerId(playerIndex))
          else
            local playerIndex = NetworkGetPlayerIndexFromPed(ped)
            table.insert(closePlayers, playerIndex)
          end
        end
      end
    end
  end
  return closePlayers
end
function Framework.getPlayerLicenses(playerId)
  local licensesPromise, licenses
  licensesPromise = promise.new()
  if "ESX" == currentFramework then
    TriggerServerCallback("esx_license:getLicenses", function(licenses)
      licensesPromise:resolve(licenses)
    end, playerId)
  elseif "QB-core" == currentFramework then
    licenses = TriggerServerPromise(Utils.eventsPrefix .. ":getPlayerLicenses", playerId)
    licensesPromise:resolve(licenses)
  end
  return Citizen.Await(licensesPromise)
end
function Framework.giveLicenseToPlayer(playerId, licenseType)
  if "ESX" == currentFramework then
    TriggerServerEvent(EXTERNAL_EVENTS_NAMES["esx_license:addLicense"], playerId, licenseType)
  elseif "QB-core" == currentFramework then
    TriggerServerEvent(Utils.eventsPrefix .. ":giveLicenseToPlayer", playerId, licenseType)
  end
end
function Framework.removeLicenseFromPlayer(playerId, licenseType)
  if "ESX" == currentFramework then
    TriggerServerEvent(EXTERNAL_EVENTS_NAMES["esx_license:removeLicense"], playerId, licenseType)
  elseif "QB-core" == currentFramework then
    TriggerServerEvent(Utils.eventsPrefix .. ":removeLicenseFromPlayer", playerId, licenseType)
  end
end
