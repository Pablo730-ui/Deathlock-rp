local activeHarvesting = {}

function notifyFinishedHarvesting(playerId, markerId, shouldContinue)
  activeHarvesting[playerId] = false
  TriggerClientEvent(Utils.eventsPrefix .. ":harvest:finishedHarvesting", playerId, markerId, shouldContinue)
end

RegisterNetEvent(Utils.eventsPrefix .. ":harvestMarkerId")
AddEventHandler(Utils.eventsPrefix .. ":harvestMarkerId", function(markerId)
  local playerId, canAccess, markerData, harvestableItems, selectedItem, itemName, itemType, quantity, itemLabel, exists, harvestTime, animations, toolItem, toolName, toolType, toolLoseQuantity, toolLoseProbability, disappearAfterUse, disappearSeconds, requiresMinimumAccountMoney, minimumAccountAmount, minimumAccountName, playerIdentifier, accountAmount, canCarry, hasTool, toolQuantity, randomValue, isClose

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  if activeHarvesting[playerId] then
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

  harvestableItems = markerData.harvestableItems
  selectedItem = getRandomElementFromTable(harvestableItems)

  itemName = selectedItem.object.name
  itemType = selectedItem.object.type
  quantity = Utils.getRandomQuantity(selectedItem.minQuantity, selectedItem.maxQuantity)
  itemLabel = Framework.getGenericObjectLabel(itemName, itemType)

  exists = Framework.doesGenericObjectExist(itemName, itemType)
  if not exists then
    print("^1'" .. itemType .. "' '" .. itemName .. "' does not exists in harvest marker '" .. markerId .. "'^7")
    notifyFinishedHarvesting(playerId, markerId, false)
    return
  end

  harvestTime = selectedItem.time
  if not harvestTime then
    harvestTime = 1
  end

  animations = markerData.animations
  if not animations then
    animations = {}
  end

  toolItem = markerData.itemTool
  toolName = toolItem and toolItem.name or nil
  toolType = toolItem and toolItem.type or nil

  if toolItem then
    exists = Framework.doesGenericObjectExist(toolName, toolType)
    if not exists then
      print("^1" .. toolType .. "' '" .. toolName .. "' does not exists in harvest marker '" .. markerId .. "'^7")
      notifyFinishedHarvesting(playerId, markerId, false)
      return
    end
  end

  toolLoseQuantity = markerData.itemToolLoseQuantity
  toolLoseProbability = markerData.itemToolLoseProbability
  disappearAfterUse = markerData.disappearAfterUse
  disappearSeconds = markerData.disappearSeconds

  if #animations == 0 then
    table.insert(animations, {
      type = "animation",
      animDict = "random@mugging4",
      animName = "pickup_low",
      animDuration = harvestTime
    })
  end

  requiresMinimumAccountMoney = markerData.requiresMinimumAccountMoney
  if requiresMinimumAccountMoney then
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
      notifyFinishedHarvesting(playerId, markerId, false)
      return
    end
  end

  harvestTime = harvestTime * 1000
  canCarry = Framework.canPlayerCarryGenericObject(playerId, itemName, itemType, quantity)
  if not canCarry then
    notifyFinishedHarvesting(playerId, markerId, false)
    notify(playerId, getLocalizedText("no_space"))
    return
  end

  activeHarvesting[playerId] = true

  if toolItem then
    toolQuantity = toolLoseQuantity or 1
    hasTool = Framework.hasPlayerEnoughOfGenericObject(playerId, toolName, toolType, toolQuantity)

    if not hasTool then
      if toolLoseQuantity then
        notify(playerId, getLocalizedText(
          "harvest:you_need_tool_count",
          toolQuantity,
          Framework.getGenericObjectLabel(toolName, toolType)
        ))
      else
        notify(playerId, getLocalizedText(
          "harvest:you_need_tool",
          Framework.getGenericObjectLabel(toolName, toolType)
        ))
      end
      notifyFinishedHarvesting(playerId, markerId, false)
      return
    end

    if toolLoseProbability then
      randomValue = math.random(1, 100)
      if toolLoseProbability >= randomValue then
        Framework.removeGenericObjectFromPlayerId(playerId, toolName, toolType, toolQuantity)
      end
    end
  end

  local progressLabel = getLocalizedText("harvest:harvesting", itemLabel)
  Dialogs.startProgressBar(playerId, harvestTime, progressLabel)
  playAnimation(playerId, animations)

  Citizen.Wait(harvestTime)

  isClose = isCloseToMarker(playerId, markerId)
  if not isClose then
    notifyFinishedHarvesting(playerId, markerId, false)
    notify(playerId, getLocalizedText("too_far"))
    return
  end

  canCarry = Framework.canPlayerCarryGenericObject(playerId, itemName, itemType, quantity)
  if not canCarry then
    notifyFinishedHarvesting(playerId, markerId, false)
    notify(playerId, getLocalizedText("no_space"))
    return
  end

  Framework.giveGenericObjectToPlayerId(playerId, selectedItem.object, quantity, true)

  Utils.log(
    playerId,
    getLocalizedText("log_harvested"),
    getLocalizedText("log_harvested_description", quantity, itemLabel, markerId),
    "success",
    "harvest"
  )

  TriggerEvent(
    Utils.eventsPrefix .. ":harvest:harvestedItem",
    playerId,
    markerId,
    itemName,
    itemType,
    quantity
  )

  if not disappearAfterUse then
    notifyFinishedHarvesting(playerId, markerId, config.allowAfkFarming)
  else
    notifyFinishedHarvesting(playerId, markerId, false)
    TriggerClientEvent(Utils.eventsPrefix .. ":harvest:hideMarker", playerId, markerId, disappearSeconds)
  end
end)
