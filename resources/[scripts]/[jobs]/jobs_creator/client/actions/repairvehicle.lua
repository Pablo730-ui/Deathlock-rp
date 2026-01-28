local isRepairing

isRepairing = false

function repairVehicle(vehicleEntity)
  local playerPed, isInVehicle, targetVehicle, canRepair, repairTime, fuelLevel, eventPrefix, eventSuffix

  if isRepairing then
    return
  end

  playerPed = PlayerPedId()
  isInVehicle = IsPedInAnyVehicle(playerPed, false)

  if isInVehicle then
    return
  end

  targetVehicle = vehicleEntity or isInVehicle
  if not vehicleEntity then
    targetVehicle = Framework.getClosestVehicle(3.0)
    vehicleEntity = targetVehicle
  end

  if not vehicleEntity then
    notifyClient(getLocalizedText("actions:no_vehicles_close"))
    return
  end

  eventPrefix = Utils.eventsPrefix
  eventSuffix = ":canRepairVehicle"
  canRepair = TriggerServerPromise(eventPrefix .. eventSuffix)

  if not canRepair then
    return
  end

  isRepairing = true
  TaskTurnPedToFaceEntity(playerPed, vehicleEntity, 1500)
  Citizen.Wait(1500)

  repairTime = 15000
  TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
  Dialogs.startProgressBar(repairTime, getLocalizedText("actions:repairing_vehicle"))
  Citizen.Wait(repairTime)

  fuelLevel = GetVehicleFuelLevel(vehicleEntity)
  SetVehicleFixed(vehicleEntity)
  SetEntityHealth(vehicleEntity, GetEntityMaxHealth(vehicleEntity))
  SetVehicleDeformationFixed(vehicleEntity)

  eventPrefix = Utils.eventsPrefix
  eventSuffix = ":vehicleRepaired"
  TriggerEvent(eventPrefix .. eventSuffix, vehicleEntity)

  SetVehicleFuelLevel(vehicleEntity, fuelLevel)
  ClearPedTasks(playerPed)
  isRepairing = false
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:repairVehicle", repairVehicle)
