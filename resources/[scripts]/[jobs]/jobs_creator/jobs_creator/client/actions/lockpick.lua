local isVehicleLocked, lockpickVehicle

function isVehicleLocked(vehicle)
  local lockStatus, isLockedForPlayer

  lockStatus = GetVehicleDoorLockStatus(vehicle)
  isLockedForPlayer = GetVehicleDoorsLockedForPlayer(vehicle)
  return 2 == lockStatus or 3 == lockStatus or isLockedForPlayer
end

function lockpickVehicle(vehicleEntity)
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)

  local targetVehicle = vehicleEntity or playerCoords
  if not vehicleEntity then
    targetVehicle = Framework.getClosestVehicle(2.0)
  end

  if not targetVehicle then
    notifyClient(getLocalizedText("no_car_found"))
    return
  end

  if not isVehicleLocked(targetVehicle) then
    notifyClient(getLocalizedText("not_locked_vehicle"))
    return
  end

  local eventPrefix = Utils.eventsPrefix
  local eventSuffix = ":canLockpickVehicle"
  local canLockpick = TriggerServerPromise(eventPrefix .. eventSuffix)

  if not canLockpick then
    notifyClient(getLocalizedText("you_need_lockpick"))
    return
  end

  local lockpickTime = config.carLockpickTime * 1000

  TaskEnterVehicle(playerPed, targetVehicle, 2000, -1, 1.0, 1, 0)
  Citizen.Wait(2000)

  Dialogs.startProgressBar(lockpickTime, getLocalizedText("actions:lockpick:lockpickingVehicle"))
  TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

  if config.enableAlarmWhenLockpicking then
    SetVehicleAlarm(targetVehicle, true)
    SetVehicleAlarmTimeLeft(targetVehicle, lockpickTime)
    StartVehicleAlarm(targetVehicle)
  end

  Citizen.Wait(lockpickTime)

  ClearPedTasks(playerPed)
  SetVehicleDoorsLockedForAllPlayers(targetVehicle, false)
  SetVehicleDoorsLocked(targetVehicle, 1)
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:lockpickCar", lockpickVehicle)
