local activeProcessing = {}

function notifyFinishedProcessing(playerId, markerId, shouldContinue)
  activeProcessing[playerId] = false
  TriggerClientEvent(Utils.eventsPrefix .. ":process:finishedProcessing", playerId, markerId, shouldContinue)
end

RegisterNetEvent(Utils.eventsPrefix .. ":process:startProcessing")
AddEventHandler(Utils.eventsPrefix .. ":process:startProcessing", function(markerId)
  local playerId, canAccess, markerData, itemToRemove, itemToRemoveQuantity, itemToAdd, itemToAddQuantity, itemToRemoveLabel, itemToAddLabel, hasEnough, canCarry, processingTime, animations, minimumAccountAmount, minimumAccountName, playerIdentifier, accountAmount, processingLabel, isClose

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  if activeProcessing[playerId] then
    return
  end

  markerData = JobsCreator.Markers[markerId]
  if not markerData then
    return
  end

  markerData = markerData.data
  if not markerData then
    return
  end

  itemToRemove = markerData.itemToRemove
  itemToRemoveQuantity = markerData.itemToRemoveQuantity
  itemToAdd = markerData.itemToAdd
  itemToAddQuantity = markerData.itemToAddQuantity

  if not itemToRemove or not itemToAdd then
    print("^1You didn't configure properly process marker ID:" .. markerId .. "^7")
    return
  end

  activeProcessing[playerId] = true

  minimumAccountAmount = markerData.requiresMinimumAccountMoney
  if minimumAccountAmount then
    minimumAccountAmount = markerData.minimumAccountAmount
    minimumAccountName = markerData.minimumAccountName

    playerIdentifier = Framework.getPlayerCharIdentifier(playerId)
    accountAmount = Framework.getAccountMoneyFromIdentifier(playerIdentifier, minimumAccountName)

    if minimumAccountAmount > accountAmount then
      notify(playerId, getLocalizedText(
        "you_need_minimum_account_money",
        minimumAccountAmount,
        Framework.getAccountLabel(minimumAccountName)
      ))
      notifyFinishedProcessing(playerId, markerId, false)
      return
    end
  end

  processingTime = markerData.timeToProcess
  animations = markerData.animations

  if not animations then
    animations = {}
  end

  itemToRemoveLabel = Framework.getGenericObjectLabel(itemToRemove.name, itemToRemove.type)
  itemToAddLabel = Framework.getGenericObjectLabel(itemToAdd.name, itemToAdd.type)

  if #animations == 0 then
    table.insert(animations, {
      type = "scenario",
      scenarioName = "PROP_HUMAN_BUM_BIN",
      scenarioDuration = processingTime
    })
  end

  hasEnough = Framework.hasPlayerEnoughOfGenericObject(playerId, itemToRemove.name, itemToRemove.type, itemToRemoveQuantity)
  if not hasEnough then
    notify(playerId, getLocalizedText("process:you_need", itemToRemoveQuantity, itemToRemoveLabel))
    notifyFinishedProcessing(playerId, markerId, false)
    return
  end

  canCarry = Framework.canPlayerCarryGenericObject(playerId, itemToAdd.name, itemToAdd.type, itemToAddQuantity)
  if not canCarry then
    notifyFinishedProcessing(playerId, markerId, false)
    notify(playerId, getLocalizedText("process:no_space", itemToAddQuantity, itemToAddLabel))
    return
  end

  Framework.removeGenericObjectFromPlayerId(playerId, itemToRemove.name, itemToRemove.type, itemToRemoveQuantity)

  processingLabel = getLocalizedText("process:processing", itemToRemoveLabel)
  Dialogs.startProgressBar(playerId, processingTime * 1000, processingLabel)
  playAnimation(playerId, animations)

  Citizen.Wait(processingTime * 1000)

  isClose = isCloseToMarker(playerId, markerId)
  if not isClose then
    notifyFinishedProcessing(playerId, markerId, false)
    notify(playerId, getLocalizedText("too_far"))
    return
  end

  Framework.giveGenericObjectToPlayerId(playerId, itemToAdd, itemToAddQuantity)
  notify(playerId, getLocalizedText("item_received", itemToAddQuantity, itemToAddLabel))
  notifyFinishedProcessing(playerId, markerId, config.allowAfkFarming)

  Utils.log(
    playerId,
    getLocalizedText("logs:process:title"),
    getLocalizedText(
      "logs:process:description",
      itemToRemoveQuantity,
      itemToRemoveLabel,
      itemToAddQuantity,
      itemToAddLabel
    ),
    "success",
    "process"
  )

  TriggerEvent(
    Utils.eventsPrefix .. ":process:processedItem",
    playerId,
    markerId,
    itemToAdd.name,
    itemToAddQuantity,
    itemToRemove.name,
    itemToRemoveQuantity
  )
end)
