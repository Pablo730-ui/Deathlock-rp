local isWashing

isWashing = false

function washVehicle(vehicleEntity)
  if isWashing then
    return
  end

  local playerPed = PlayerPedId()
  local isInVehicle = IsPedInAnyVehicle(playerPed, false)

  if isInVehicle then
    return
  end

  local playerCoords = GetEntityCoords(playerPed)

  if not vehicleEntity then
    local targetVehicle = Framework.getClosestVehicle(3.0)
    vehicleEntity = targetVehicle
  end

  if not vehicleEntity then
    notifyClient(getLocalizedText("actions:no_vehicles_close"))
    return
  end

  SetVehicleDirtLevel(vehicleEntity, 10.0)

  local eventPrefix = Utils.eventsPrefix
  local eventSuffix = ":canWashVehicle"
  local canWash = TriggerServerPromise(eventPrefix .. eventSuffix)

  if not canWash then
    return
  end

  isWashing = true
  TaskTurnPedToFaceEntity(playerPed, vehicleEntity, 1500)
  Citizen.Wait(1500)

  TaskStartScenarioInPlace(playerPed, "world_human_maid_clean", 0, true)
  local dirtLevel = GetVehicleDirtLevel(vehicleEntity)
  local progressDuration = dirtLevel * 1000

  Dialogs.startProgressBar(progressDuration, getLocalizedText("actions:washing_vehicle"))

  while dirtLevel >= 0.0 do
    Citizen.Wait(1000)
    dirtLevel = dirtLevel - 1.0
    SetVehicleDirtLevel(vehicleEntity, dirtLevel)
  end

  ClearPedTasks(playerPed)
  isWashing = false
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:washVehicle", washVehicle)
