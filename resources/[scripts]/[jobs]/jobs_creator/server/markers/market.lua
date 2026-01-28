local activeSellingTimers = {}

function notifyFinishedSelling(playerId, marketId, shouldContinue)
  activeSellingTimers[playerId] = false
  TriggerClientEvent(Utils.eventsPrefix .. ":market:finishedSelling", playerId, marketId, shouldContinue)
end

RegisterServerCallback(Utils.eventsPrefix .. ":getMarketItems", function(source, callback, marketId)
  local playerId, canAccess, markerData, marketItems, i, item, itemData, itemLabel

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, marketId)
  if not canAccess then
    return
  end

  markerData = JobsCreator.Markers[marketId]
  if markerData then
    markerData = markerData.data
    if markerData then
      marketItems = {}
      if markerData.items then
        for i = 1, #markerData.items, 1 do
          item = markerData.items[i]
          itemLabel = getLocalizedText(
            "market_item",
            Framework.getGenericObjectLabel(item.object.name, item.object.type),
            item.minPrice,
            item.maxPrice
          )

          itemData = {}
          itemData.label = itemLabel
          itemData.value = i
          table.insert(marketItems, itemData)
        end
      end
      callback(marketItems)
    else
      callback({})
    end
  else
    callback({})
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":sellMarketItem")
AddEventHandler(Utils.eventsPrefix .. ":sellMarketItem", function(marketId, itemIndex, quantity)
  local playerId, canAccess, markerData, itemData, itemObject, isAlreadySelling, itemLabel, hasEnough, sellTime, totalTime, societyMoney, colorPrefix, notificationMessage, logMessage, logDescription

  if quantity <= 0 then
    return
  end

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, marketId)
  if not canAccess then
    return
  end

  markerData = JobsCreator.Markers[marketId]
  if markerData then
    markerData = markerData.data
    if markerData then
      if markerData.items then
        itemData = markerData.items[itemIndex]
        if itemData then
          itemObject = itemData.object

          isAlreadySelling = activeSellingTimers[playerId]
          if isAlreadySelling then
            notify(playerId, getLocalizedText("market:you_are_already_selling"))
            return
          end

          itemLabel = Framework.getGenericObjectLabel(itemObject.name, itemObject.type)
          hasEnough = Framework.hasPlayerEnoughOfGenericObject(playerId, itemObject.name, itemObject.type, quantity)

          if not hasEnough then
            notify(playerId, getLocalizedText("not_enough_item", itemLabel))
            return
          end

          sellTime = itemData.sellTime
          if not sellTime then
            sellTime = 0
          end
          totalTime = sellTime * 1000 * quantity

          if totalTime > 0 then
            local progressLabel = getLocalizedText("market:selling", quantity, itemLabel)
            Dialogs.startProgressBar(playerId, totalTime, progressLabel)
            timedFreezePlayer(playerId, totalTime)
          end

          TriggerClientEvent(Utils.eventsPrefix .. ":market:toggleSelling", playerId, true)

          activeSellingTimers[playerId] = Timeout(totalTime, function()
            hasEnough = Framework.hasPlayerEnoughOfGenericObject(playerId, itemObject.name, itemObject.type, quantity)
            if hasEnough then
              Framework.removeGenericObjectFromPlayerId(playerId, itemObject.name, itemObject.type, quantity)
              local totalPrice = Utils.getRandomQuantity(itemData.minPrice, itemData.maxPrice) * quantity
              local jobName = JobsCreator.Markers[marketId].jobName

              if jobName ~= "public_marker" then
                local percentageForSociety = markerData.percentageForSociety
                if percentageForSociety then
                  societyMoney = math.floor(totalPrice * percentageForSociety / 100)
                  totalPrice = totalPrice - societyMoney

                  local resourceName = GetCurrentResourceName()
                  local success = exports[resourceName].addSocietyMoney(jobName, societyMoney)

                  if success then
                    notify(playerId, getLocalizedText("society_received_money_from_your_sale", Framework.groupDigits(societyMoney)))
                  else
                    TriggerClientEvent(Utils.eventsPrefix .. ":market:toggleSelling", playerId, false)
                    print("^1Couldn't give money to society ^3" .. jobName .. "^1 (try deleting and recreating the job)^7")
                    return
                  end
                end
              end

              if itemData.blackMoney then
                Framework.giveBlackMoneyValue(playerId, totalPrice)
              else
                local framework = Framework.getFramework()
                if framework == "ESX" then
                  Framework.giveAccountMoneyToPlayer(playerId, "money", totalPrice)
                elseif framework == "QB-core" then
                  Framework.giveAccountMoneyToPlayer(playerId, "cash", totalPrice)
                end
              end

              if itemData.blackMoney then
                colorPrefix = "~r~"
              else
                colorPrefix = "~g~"
              end

              if totalPrice > 0 then
                notificationMessage = getLocalizedText(
                  "you_sold",
                  quantity,
                  itemLabel,
                  colorPrefix,
                  Framework.groupDigits(totalPrice)
                )
                notify(playerId, notificationMessage)
              end

              logMessage = getLocalizedText("log_sold_item")
              logDescription = getLocalizedText(
                "log_sold_item_description",
                quantity,
                itemLabel,
                Framework.groupDigits(totalPrice)
              )
              Utils.log(playerId, logMessage, logDescription, "success", "market")

              TriggerEvent(
                Utils.eventsPrefix .. ":market:soldItem",
                playerId,
                marketId,
                itemObject.name,
                quantity,
                totalPrice
              )
            else
              notify(playerId, getLocalizedText("not_enough_item", itemLabel))
            end

            TriggerClientEvent(Utils.eventsPrefix .. ":market:toggleSelling", playerId, false)
            activeSellingTimers[playerId] = nil
          end)
        end
      end
    end
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":market:stopSelling")
AddEventHandler(Utils.eventsPrefix .. ":market:stopSelling", function()
  local playerId, timeoutId

  playerId = source
  timeoutId = activeSellingTimers[playerId]

  if timeoutId then
    print("Timeout ID: " .. tostring(timeoutId))
    ClearTimeout(timeoutId)
    activeSellingTimers[playerId] = nil
  end

  TriggerClientEvent(Utils.eventsPrefix .. ":market:toggleSelling", playerId, false)
end)
