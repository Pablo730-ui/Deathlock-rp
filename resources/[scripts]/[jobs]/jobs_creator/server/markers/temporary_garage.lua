local spawnedVehicles = {}

RegisterServerCallback(Utils.eventsPrefix .. ":retrieveVehicles", function(playerId, callback, markerId)
  local vehicles, vehicleName, vehicleData, isOutside, entityNetId, entity, uniqueId, vehicleInfo

  vehicles = {}

  for vehicleName, vehicleData in pairs(JobsCreator.Markers[markerId].data.vehicles) do
    isOutside = false

    vehicleInfo = spawnedVehicles[playerId]
    if vehicleInfo then
      vehicleInfo = vehicleInfo[markerId]
      if vehicleInfo then
        vehicleInfo = vehicleInfo[vehicleName]
      end
    end

    if vehicleInfo then
      entityNetId = vehicleInfo.netId
      if entityNetId then
        entity = NetworkGetEntityFromNetworkId(entityNetId)
        if entity ~= 0 then
          if DoesEntityExist(entity) then
            uniqueId = vehicleInfo.uniqueId
            if uniqueId == Utils.getUniqueEntityId(entity) then
              isOutside = true
            end
          end
        else
          vehicleInfo = nil
        end
      end
    end

    vehicles[vehicleName] = vehicleData
    vehicles[vehicleName].isOutside = isOutside
  end

  callback({
    vehicles = vehicles,
    spawnPoints = JobsCreator.Markers[markerId].data.spawnPoints
  })
end)

RegisterNetEvent(Utils.eventsPrefix .. ":temporary_garage:spawnedVehicle", function(markerId, vehicleName, vehicleNetId)
  local playerId, playerVehicles, markerVehicles, entity, uniqueId

  playerId = source

  if not spawnedVehicles[playerId] then
    spawnedVehicles[playerId] = {}
  end

  if not spawnedVehicles[playerId][markerId] then
    spawnedVehicles[playerId][markerId] = {}
  end

  entity = NetworkGetEntityFromNetworkId(vehicleNetId)
  if not DoesEntityExist(entity) then
    return
  end

  uniqueId = Utils.getUniqueEntityId(entity)

  spawnedVehicles[playerId][markerId][vehicleName] = {
    netId = vehicleNetId,
    uniqueId = uniqueId
  }
end)

AddEventHandler("playerDropped", function()
  local playerId

  playerId = source
  if spawnedVehicles[playerId] then
    spawnedVehicles[playerId] = nil
  end
end)
