function getStashData(stashId)
  local markerData

  markerData = JobsCreator.Markers[stashId]
  if markerData then
    markerData = markerData.data
  end
  return markerData
end

RegisterServerCallback(Utils.eventsPrefix .. ":retrieveStash", function(source, callback, stashId)
  local playerId, canAccess, player, stashData, items, itemName, itemQuantity, itemLabel, itemData

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, stashId)
  if not canAccess then
    return
  end

  player = ESX.GetPlayerFromId(playerId)
  stashData = getStashData(stashId)
  items = {}

  for itemName, itemQuantity in pairs(stashData) do
    itemLabel = string.format(
      "%s - x%d",
      Framework.getItemLabel(itemName),
      itemQuantity
    )

    itemData = {}
    itemData.label = itemLabel
    itemData.value = itemName
    itemData.quantity = itemQuantity
    table.insert(items, itemData)
  end

  callback(items)
end)

function addItemToStash(stashId, itemName, quantity, callback)
  local markerData, currentQuantity

  markerData = JobsCreator.Markers[stashId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  currentQuantity = markerData[itemName]
  if currentQuantity then
    currentQuantity = markerData[itemName]
    currentQuantity = currentQuantity + quantity
    markerData[itemName] = currentQuantity
  else
    markerData[itemName] = quantity
  end

  MySQL.Async.execute(
    "UPDATE jobs_data SET data=@inventory WHERE id=@markerId",
    {
      ["@inventory"] = json.encode(markerData),
      ["@markerId"] = stashId
    },
    function(affectedRows)
      if affectedRows > 0 then
        JobsCreator.Markers[stashId].data = markerData
        callback(true)
      else
        callback(false)
      end
    end
  )
end

function removeItemFromStash(stashId, itemName, quantity, callback)
  local markerData, currentQuantity

  markerData = JobsCreator.Markers[stashId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  currentQuantity = markerData[itemName]
  if currentQuantity then
    if quantity <= currentQuantity then
      currentQuantity = markerData[itemName]
      currentQuantity = currentQuantity - quantity
      markerData[itemName] = currentQuantity

      if markerData[itemName] == 0 then
        markerData[itemName] = nil
      end

      MySQL.Async.execute(
        "UPDATE jobs_data SET data=@inventory WHERE id=@markerId",
        {
          ["@inventory"] = json.encode(markerData),
          ["@markerId"] = stashId
        },
        function(affectedRows)
          if affectedRows > 0 then
            JobsCreator.Markers[stashId].data = markerData
            callback(true)
          else
            callback(false)
          end
        end
      )
    else
      callback(false)
    end
  else
    callback(false)
  end
end

function clearStashInventory(stashId)
  local promise, framework

  promise = promise.new()

  framework = Framework.getFramework()
  if framework == "ESX" then
    MySQL.Async.execute(
      "UPDATE jobs_data SET data=\"{}\" WHERE id=@markerId AND type=\"stash\"",
      {
        ["@markerId"] = stashId
      },
      function(affectedRows)
        if affectedRows > 0 then
          JobsCreator.Markers[stashId].data = {}
          promise:resolve({
            isSuccessful = true,
            message = "Successful"
          })
        else
          promise:resolve({
            isSuccessful = false,
            message = "Couldn't delete stash inventory"
          })
        end
      end
    )
  else
    framework = Framework.getFramework()
    if framework == "QB-core" then
      MySQL.Async.execute(
        "UPDATE stashitems SET items='[]' WHERE stash = @stashId",
        {
          ["@stashId"] = "stash_" .. stashId
        },
        function(affectedRows)
          if affectedRows > 0 then
            JobsCreator.Markers[stashId].data = {}
            promise:resolve({
              isSuccessful = true,
              message = "Successful"
            })
          else
            promise:resolve({
              isSuccessful = false,
              message = "Couldn't delete stash inventory"
            })
          end
        end
      )
    end
  end

  return Citizen.Await(promise)
end

RegisterServerCallback(Utils.eventsPrefix .. ":deleteStashInventory", function(source, callback, stashId)
  local playerId, isAllowed

  playerId = source

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    clearStashInventory(stashId)
    callback(true)
  else
    callback(false)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":stash:takeItem", function(source, callback, stashId, itemName, quantity)
  local playerId, canAccess, player, jobName, jobGrade, canCarry

  if quantity <= 0 then
    return
  end

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, stashId)
  if not canAccess then
    return
  end

  player = ESX.GetPlayerFromId(playerId)
  jobName = player.job.name
  jobGrade = player.job.grade

  canCarry = Framework.canPlayerCarryItem(playerId, itemName, quantity)
  if canCarry then
    removeItemFromStash(stashId, itemName, quantity, function(success)
      if success then
        player.addInventoryItem(itemName, quantity)
        notify(player.source, getLocalizedText("took", quantity, Framework.getItemLabel(itemName)))
        Utils.log(
          playerId,
          getLocalizedText("log_took_stash"),
          getLocalizedText(
            "log_took_stash_description",
            quantity,
            Framework.getItemLabel(itemName),
            itemName,
            stashId
          ),
          "success",
          "stash"
        )
        callback(true)
      else
        notify(player.source, getLocalizedText("impossible_take", quantity, Framework.getItemLabel(itemName)))
        callback(false)
      end
    end)
  else
    notify(player.source, getLocalizedText("no_space"))
    callback(false)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":stash:depositItem", function(source, callback, stashId, itemName, quantity)
  local playerId, canAccess, player, jobName, jobGrade, inventoryItem, itemCount, itemLabel

  if quantity <= 0 then
    return
  end

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, stashId)
  if not canAccess then
    return
  end

  player = ESX.GetPlayerFromId(playerId)
  jobName = player.job.name
  jobGrade = player.job.grade

  inventoryItem = player.getInventoryItem(itemName)
  itemCount = inventoryItem.count

  if quantity <= itemCount then
    notify(player.source, getLocalizedText("deposited", quantity, inventoryItem.label))
    player.removeInventoryItem(itemName, quantity)
    Utils.log(
      playerId,
      getLocalizedText("log_deposited_stash"),
      getLocalizedText("log_deposited_stash_description", quantity, inventoryItem.label, itemName, stashId),
      "success",
      "stash"
    )
    addItemToStash(stashId, itemName, quantity, callback)
  else
    notify(player.source, getLocalizedText("not_enough", inventoryItem.label))
    callback(false)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getPlayerInventory", function(source, callback)
  local playerId, player, items, itemName, itemData, itemLabel, itemCount

  playerId = source
  player = ESX.GetPlayerFromId(playerId)
  items = {}

  for itemName, itemData in pairs(player.getInventory(true)) do
    itemLabel = Framework.getItemLabel(itemName)

    if type(itemData) == "table" then
      itemName = itemData.name
      itemLabel = itemData.label or itemLabel or Framework.getItemLabel(itemName) or itemName
      itemCount = itemData.count
    end

    if itemCount > 0 then
      itemLabel = string.format("%s - x%d", itemLabel, itemCount)

      table.insert(items, {
        label = itemLabel,
        value = itemName,
        quantity = itemCount
      })
    end
  end

  callback(items)
end)
