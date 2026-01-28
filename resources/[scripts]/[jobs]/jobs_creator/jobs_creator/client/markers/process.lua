local isProcessing

isProcessing = false

function processMarker(markerId)
  local playerPed, isInVehicle, errorMessage, localizedText, eventPrefix, eventSuffix

  playerPed = PlayerPedId()
  isInVehicle = IsPedInAnyVehicle(playerPed, true)
  if isInVehicle then
    localizedText = getLocalizedText("you_cant_do_this_in_a_vehicle")
    notifyClient(localizedText)
    return
  end

  if isProcessing then
    return
  end

  isProcessing = true

  eventPrefix = Utils.eventsPrefix
  eventSuffix = ":process:startProcessing"
  eventPrefix = eventPrefix .. eventSuffix
  TriggerServerEvent(eventPrefix, markerId)

  Citizen.CreateThread(function()
    local stopText, waitTime, isControlReleased, controlId, controlKey

    stopText = getLocalizedText("process:press_to_stop")

    while isProcessing do
      Citizen.Wait(0)

      showHelpNotification(stopText)

      controlId = 0
      controlKey = 38
      isControlReleased = IsControlJustReleased(controlId, controlKey)

      if isControlReleased then
        isProcessing = false
        localizedText = getLocalizedText("process:you_will_stop_on_finish")
        notifyClient(localizedText)
      end
    end
  end)
end

function onProcessFinished(markerId, shouldContinue)
  local isCurrentlyProcessing, eventPrefix, eventSuffix

  isCurrentlyProcessing = isProcessing
  if isCurrentlyProcessing and shouldContinue then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":process:startProcessing"
    eventPrefix = eventPrefix .. eventSuffix
    TriggerServerEvent(eventPrefix, markerId)
  elseif not shouldContinue then
    isProcessing = false
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":process:finishedProcessing", onProcessFinished)
