local isHarvesting

isHarvesting = false

function harvestMarker(markerId)
  local playerPed, isInVehicle, errorMessage, localizedText, eventPrefix, eventSuffix

  playerPed = PlayerPedId()
  isInVehicle = IsPedInAnyVehicle(playerPed, true)
  if isInVehicle then
    localizedText = getLocalizedText("you_cant_do_this_in_a_vehicle")
    notifyClient(localizedText)
    return
  end

  if isHarvesting then
    return
  end

  isHarvesting = true

  eventPrefix = Utils.eventsPrefix
  eventSuffix = ":harvestMarkerId"
  eventPrefix = eventPrefix .. eventSuffix
  TriggerServerEvent(eventPrefix, markerId)

  if not config.allowAfkFarming then
    return
  end

  Citizen.CreateThread(function()
    local stopText, waitTime, isControlReleased, controlId, controlKey

    stopText = getLocalizedText("harvest:press_to_stop")

    while isHarvesting do
      Citizen.Wait(0)

      showHelpNotification(stopText)

      controlId = 0
      controlKey = 38
      isControlReleased = IsControlJustReleased(controlId, controlKey)

      if isControlReleased then
        isHarvesting = false
        localizedText = getLocalizedText("harvest:you_will_stop_on_finish")
        notifyClient(localizedText)
      end
    end
  end)
end

function onHarvestFinished(markerId, shouldContinue)
  local isCurrentlyHarvesting, eventPrefix, eventSuffix

  isCurrentlyHarvesting = isHarvesting
  if isCurrentlyHarvesting and shouldContinue then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":harvestMarkerId"
    eventPrefix = eventPrefix .. eventSuffix
    TriggerServerEvent(eventPrefix, markerId)
  elseif not shouldContinue then
    isHarvesting = false
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":harvest:finishedHarvesting", onHarvestFinished)
