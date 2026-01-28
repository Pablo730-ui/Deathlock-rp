local isImpounding

isImpounding = false

function impoundVehicle(vehicleEntity)
  local playerPed, isInVehicle, closestVehicle, plateText, vehicleName, entityModel, progressDuration

  if isImpounding then
    return
  end

  playerPed = PlayerPedId()
  isInVehicle = IsPedInAnyVehicle(playerPed, false)

  if isInVehicle then
    return
  end

  if not vehicleEntity then
    closestVehicle = Framework.getClosestVehicle(3.0)
    vehicleEntity = closestVehicle
  end

  if not vehicleEntity then
    notifyClient(getLocalizedText("actions:no_vehicles_close"))
    return
  end

  isImpounding = true
  plateText = GetVehicleNumberPlateText(vehicleEntity)
  entityModel = GetEntityModel(vehicleEntity)
  vehicleName = getVehicleNameFromModel(entityModel)

  TaskTurnPedToFaceEntity(playerPed, vehicleEntity, 1500)
  Citizen.Wait(1500)

  progressDuration = 10000
  TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
  Dialogs.startProgressBar(progressDuration, getLocalizedText("actions:impounding_vehicle"))
  Citizen.Wait(progressDuration)

  if DoesEntityExist(vehicleEntity) then
    Framework.deleteVehicle(vehicleEntity)
  end

  ClearPedTasks(playerPed)

  local eventPrefix = Utils.eventsPrefix
  local eventSuffix = ":actions:vehicleImpounded"
  TriggerEvent(eventPrefix .. eventSuffix, plateText, vehicleName)

  isImpounding = false
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:impoundVehicle", impoundVehicle)
