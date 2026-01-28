local playerVehicles = {}
local vehicleIdToNetId = {}
local netIdToVehicleId = {}

RegisterServerCallback(Utils.eventsPrefix .. ":getGarageBuyableData", function(playerId, callback, markerId)
  local canAccess, markerData

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  callback(markerData)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":buyVehicleFromGarage")
AddEventHandler(Utils.eventsPrefix .. ":buyVehicleFromGarage", function(markerId, vehicleName)
  local playerId, identifier, markerData, vehiclePrice, wasPaid, insertId, plate

  playerId = source
  identifier = Framework.getPlayerCharIdentifier(playerId)

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  vehiclePrice = markerData.vehicles[vehicleName]
  if vehiclePrice then
    wasPaid = payInSomeWay(playerId, vehiclePrice)
    if wasPaid then
      notify(playerId, getLocalizedText("bought_vehicle"))
      Utils.log(
        playerId,
        getLocalizedText("log_bought_vehicle"),
        getLocalizedText("log_bought_vehicle_description", vehicleName, vehiclePrice, markerId),
        "success",
        "permanent_garage"
      )

      plate = generatePlate()

      MySQL.Async.insert(
        "INSERT INTO jobs_garages(identifier, marker_id, vehicle, vehicle_props, plate) VALUES (@identifier, @markerId, @vehicle, \"{}\", @plate)",
        {
          ["@identifier"] = identifier,
          ["@markerId"] = markerId,
          ["@vehicle"] = vehicleName,
          ["@plate"] = plate
        },
        function(insertId)
          if insertId > 0 then
            if not playerVehicles[identifier] then
              playerVehicles[identifier] = {}
            end

            if not playerVehicles[identifier][markerId] then
              playerVehicles[identifier][markerId] = {}
            end

            playerVehicles[identifier][markerId][insertId] = {
              vehicleId = insertId,
              vehicle = vehicleName,
              identifier = identifier,
              vehicleProps = {},
              markerId = markerId,
              plate = plate
            }

            TriggerEvent(
              Utils.eventsPrefix .. ":permanent_garage:vehicleBought",
              playerId,
              markerId,
              vehicleName,
              insertId
            )
          end
        end
      )
    else
      notify(playerId, getLocalizedText("not_enough_money"))
    end
  else
    Utils.log(
      playerId,
      getLocalizedText("log_not_existing_vehicle"),
      getLocalizedText("log_not_existing_vehicle_description", vehicleName, markerId),
      "error",
      "permanent_garage"
    )
  end
end)

function getAllGaragesData()
  MySQL.Async.fetchAll("SELECT * FROM jobs_garages", {}, function(results)
    local identifier, markerId, vehicleId, vehicleProps

    if results then
      for _, vehicleData in pairs(results) do
        identifier = vehicleData.identifier
        markerId = vehicleData.marker_id
        vehicleId = vehicleData.vehicle_id

        if not playerVehicles[identifier] then
          playerVehicles[identifier] = {}
        end

        if not playerVehicles[identifier][markerId] then
          playerVehicles[identifier][markerId] = {}
        end

        vehicleProps = json.decode(vehicleData.vehicle_props)

        playerVehicles[identifier][markerId][vehicleId] = {
          plate = vehicleData.plate,
          markerId = markerId,
          vehicle = vehicleData.vehicle,
          vehicleProps = vehicleProps,
          vehicleId = vehicleId
        }
      end
    end
  end)
end

function isVehicleSpawned(vehicleId)
  local vehicleInfo, netId, entity, uniqueId

  vehicleInfo = netIdToVehicleId[vehicleId]
  if not vehicleInfo then
    return false
  end

  netId = vehicleInfo.netId
  if netId then
    entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
      uniqueId = Utils.getUniqueEntityId(entity)
      if uniqueId == vehicleInfo.uniqueId then
        return true
      end
    end
  end

  return false
end

function getPlayerVehiclesInMarkerId(playerId, markerId)
  local identifier, vehicles, markerVehicles, vehicleId, vehicleData

  identifier = Framework.getPlayerCharIdentifier(playerId)
  vehicles = {}

  markerVehicles = playerVehicles[identifier]
  if markerVehicles then
    markerVehicles = markerVehicles[markerId]
  end

  if markerVehicles then
    for vehicleId, vehicleData in pairs(markerVehicles) do
      vehicleData.isOutside = isVehicleSpawned(vehicleId)
      vehicles[vehicleId] = vehicleData
    end
  end

  return vehicles
end
exports("getPlayerVehiclesInMarkerId", getPlayerVehiclesInMarkerId)

RegisterServerCallback(Utils.eventsPrefix .. ":getGarageOwnedVehicles", function(playerId, callback, markerId)
  local vehicles, markerData

  vehicles = getPlayerVehiclesInMarkerId(playerId, markerId)

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if markerData then
    callback({
      vehicles = vehicles,
      spawnPoints = markerData.spawnPoints
    })
  else
    callback({
      vehicles = {}
    })
  end
end)

RegisterServerCallback(
  Utils.eventsPrefix .. ":permanent_garage:updateVehicleProps",
  function(playerId, callback, markerId, vehicleNetId, vehicleId, props, plate)
    local identifier, oldVehicleId, entity, entityOwner, wasUpdated

    identifier = Framework.getPlayerCharIdentifier(playerId)

    oldVehicleId = vehicleIdToNetId[vehicleNetId]
    if not oldVehicleId then
      callback(false)
      return
    else
      vehicleIdToNetId[vehicleNetId] = nil
      netIdToVehicleId[oldVehicleId] = nil

      entity = NetworkGetEntityFromNetworkId(vehicleNetId)
      entityOwner = NetworkGetEntityOwner(entity)

      TriggerClientEvent(
        Utils.eventsPrefix .. ":framework:deleteVehicle",
        entityOwner,
        vehicleNetId
      )
      callback(true)
    end

    MySQL.Async.execute(
      "UPDATE jobs_garages SET vehicle_props=@props, marker_id=@markerId WHERE vehicle_id=@vehicleId AND identifier=@identifier",
      {
        ["@props"] = json.encode(props),
        ["@vehicleId"] = oldVehicleId,
        ["@identifier"] = identifier,
        ["@markerId"] = markerId
      },
      function(affectedRows)
        local found, markerIdIter, markerVehicles, vehicleIdIter, vehicleData

        if affectedRows > 0 then
          found = false

          for markerIdIter, markerVehicles in pairs(playerVehicles[identifier]) do
            if found then
              break
            end

            for vehicleIdIter, vehicleData in pairs(markerVehicles) do
              if vehicleIdIter == oldVehicleId then
                playerVehicles[identifier][markerIdIter][vehicleIdIter] = nil
                vehicleData.markerId = markerId
                vehicleData.vehicleProps = props

                if not playerVehicles[identifier][markerId] then
                  playerVehicles[identifier][markerId] = {}
                end

                playerVehicles[identifier][markerId][oldVehicleId] = vehicleData

                found = true
                break
              end
            end
          end

          MySQL.Async.execute(
            "UPDATE jobs_garages SET plate=@plate WHERE plate IS NULL AND vehicle_id=@vehicleId AND identifier=@identifier",
            {
              ["@plate"] = plate,
              ["@vehicleId"] = oldVehicleId,
              ["@identifier"] = identifier
            },
            function(affectedRows)
              if affectedRows > 0 then
                playerVehicles[identifier][markerId][oldVehicleId].plate = plate
              end
            end
          )
        end
      end
    )
  end
)

RegisterNetEvent(Utils.eventsPrefix .. ":permanent_garage:vehicleIdSpawned", function(vehicleId, vehicleNetId)
  local entity, uniqueId

  entity = NetworkGetEntityFromNetworkId(vehicleNetId)
  uniqueId = Utils.getUniqueEntityId(entity)

  vehicleIdToNetId[vehicleNetId] = vehicleId
  netIdToVehicleId[vehicleId] = {
    netId = vehicleNetId,
    uniqueId = uniqueId
  }
end)

function getAllVehiclesOfPlayer(playerId)
  local identifier, allVehicles, playerData, markerId, vehicles, vehicleId, vehicleData

  identifier = Framework.getPlayerCharIdentifier(playerId)
  allVehicles = {}

  playerData = playerVehicles[identifier]
  if playerData then
    for markerId, vehicles in pairs(playerData) do
      for vehicleId, vehicleData in pairs(vehicles) do
        allVehicles[vehicleId] = vehicleData
      end
    end
    return allVehicles
  else
    return nil
  end
end
exports("getAllVehiclesOfPlayer", getAllVehiclesOfPlayer)

function isPlayerOwnerOfVehiclePlate(playerId, plate)
  local identifier, trimmedPlate, playerData, markerId, vehicles, vehicleId, vehicleData

  identifier = Framework.getPlayerCharIdentifier(playerId)
  trimmedPlate = Framework.trim(plate)

  playerData = playerVehicles[identifier]
  if playerData then
    for markerId, vehicles in pairs(playerData) do
      for vehicleId, vehicleData in pairs(vehicles) do
        if vehicleData.plate == plate or vehicleData.plate == trimmedPlate then
          return true
        end
      end
    end
  end

  return false
end
exports("isPlayerOwnerOfVehiclePlate", isPlayerOwnerOfVehiclePlate)
